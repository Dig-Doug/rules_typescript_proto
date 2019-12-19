package test.integration;

import static com.google.common.truth.Truth.assertThat;

import com.google.devtools.build.runfiles.Runfiles;
import com.google.testing.web.WebTest;
import io.grpc.Server;
import io.grpc.ServerBuilder;
import io.grpc.stub.StreamObserver;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Date;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicLong;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.logging.LogEntries;
import org.openqa.selenium.logging.LogEntry;
import org.openqa.selenium.logging.LogType;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import test.integration.proto.Service;
import test.integration.proto.TestServiceGrpc.TestServiceImplBase;

@RunWith(JUnit4.class)
public class IntegrationTest {
  private static final By DO_UNARY_RPC_BUTTON = By.id("do-unary-rpc");
  private static final By RPC_RESPONSE_FIELD = By.id("rpc-response-field");
  private static final String UNARY_RPC_PAYLOAD = "unary-rpc-payload";
  // NOTE: These ports must match the envoy config
  private static final int HTTP_SERVER_PORT = 5434;
  private static final int GRPC_SERVER_PORT = 19020;
  private static final int ENVOY_PROXY_PORT = 10002;

  private static Process httpServerProcess;
  private static Process envoyProcess;
  private static Server grpcServer;
  private static TestServiceImpl grpcServiceImpl;

  private WebDriver driver;
  private WebDriverWait wait;

  @BeforeClass
  public static void beforeAll() throws Exception {
    Runfiles runfiles = Runfiles.create();
    httpServerProcess = startWebServer(runfiles, HTTP_SERVER_PORT);
    envoyProcess = startEnvoyProxy(runfiles);
    grpcServiceImpl = new TestServiceImpl();
    grpcServer = ServerBuilder.forPort(GRPC_SERVER_PORT).addService(grpcServiceImpl).build();
    grpcServer.start();
  }

  @AfterClass
  public static void afterAll() throws Exception {
    stopProcess(httpServerProcess);
    stopProcess(envoyProcess);
    if (grpcServer != null) {
      grpcServer.awaitTermination(5, TimeUnit.SECONDS);
    }
  }

  private static void stopProcess(Process process) {
    if (process == null) {
      return;
    }
    process.destroy();
    try {
      process.waitFor(5, TimeUnit.SECONDS);
    } catch (InterruptedException e) {
      process.destroyForcibly();
    }
  }

  @Before
  public void createDriver() {
    driver = new WebTest().newWebDriverSession();
    driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);
    wait = new WebDriverWait(driver, 1);

    driver.get(String.format("http://localhost:%d", ENVOY_PROXY_PORT));
  }

  @After
  public void quitDriver() {
    logBrowserLogs();
    try {
      driver.quit();
    } finally {
      driver = null;
    }

    grpcServiceImpl.reset();
  }

  @Test
  public void unaryRpc() {
    assertThat(grpcServiceImpl.getUnaryCount()).isEqualTo(0);

    wait.until(ExpectedConditions.presenceOfElementLocated(DO_UNARY_RPC_BUTTON));
    getElement(DO_UNARY_RPC_BUTTON).click();
    wait.until(ExpectedConditions.textToBePresentInElement(
        getElement(RPC_RESPONSE_FIELD), UNARY_RPC_PAYLOAD));

    assertThat(grpcServiceImpl.getUnaryCount()).isEqualTo(1);
  }

  private WebElement getElement(By by) {
    return driver.findElement(by);
  }

  private static Process startWebServer(Runfiles runfiles, int serverPort) throws Exception {
    String path =
        runfiles.rlocation("rules_typescript_proto/test/integration/client/prodserver.sh");
    ProcessBuilder pb =
        new ProcessBuilder(path, "--port", Integer.toString(serverPort)).redirectErrorStream(true);
    pb.environment().putAll(runfiles.getEnvVars());
    Process p = pb.start();
    waitForReadyMessage(p, "listening on");
    return p;
  }

  private static Process startEnvoyProxy(Runfiles runfiles) throws Exception {
    String path = runfiles.rlocation("rules_typescript_proto/test/integration/envoy.yaml");
    ProcessBuilder pb =
        new ProcessBuilder("envoy", "--config-path", path).redirectErrorStream(true);
    pb.environment().putAll(runfiles.getEnvVars());
    Process p = pb.start();
    waitForReadyMessage(p, "starting main dispatch loop");
    return p;
  }

  private static void waitForReadyMessage(Process p, String readyMessage) throws Exception {
    InputStream is = p.getInputStream();
    InputStreamReader isr = new InputStreamReader(is);
    BufferedReader br = new BufferedReader(isr);
    String line;
    while ((line = br.readLine()) != null) {
      System.err.println(line);
      if (line.contains(readyMessage)) {
        break;
      }
    }
  }

  private void logBrowserLogs() {
    LogEntries logEntries = driver.manage().logs().get(LogType.BROWSER);
    for (LogEntry entry : logEntries) {
      System.err.println(String.format("BROWSER: %s %s %s", new Date(entry.getTimestamp()),
          entry.getLevel(), entry.getMessage()));
    }
  }

  private static class TestServiceImpl extends TestServiceImplBase {
    private final AtomicLong unaryCount = new AtomicLong(0);

    public long getUnaryCount() {
      return unaryCount.get();
    }

    public void reset() {
      unaryCount.set(0);
    }

    @Override
    public void unaryRpc(
        Service.TestRequest request, StreamObserver<Service.TestResponse> responseObserver) {
      unaryCount.incrementAndGet();

      responseObserver.onNext(
          Service.TestResponse.newBuilder().setPayload(UNARY_RPC_PAYLOAD).build());
      responseObserver.onCompleted();
    }
  }
}
