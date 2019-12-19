import {Component, ElementRef, ViewChild} from '@angular/core';
import {grpc} from '@improbable-eng/grpc-web';
import {TestRequest, TestResponse} from 'rules_typescript_proto/test/integration/proto/service_pb';
import {TestServiceClient} from 'rules_typescript_proto/test/integration/proto/service_pb_service';

@Component({selector: 'app-component', templateUrl: 'app.component.html'})
export class AppComponent {
  rpcResponse: string;

  doUnaryRpc() {
    const client = new TestServiceClient('/_/api', {transport: grpc.CrossBrowserHttpTransport({})});

    const req = new TestRequest();
    const responsePromise = new Promise<TestResponse>((resolve, reject) => {
      client.unaryRpc(req, undefined, (err, response) => {
        if (err) {
          reject(err);
        } else {
          resolve(response);
        }
      });
    });

    responsePromise
        .then((response: any) => {
          this.rpcResponse = response.getPayload();
        })
        .catch((e: Error) => {
          this.rpcResponse = e.stack;
        })
  }
}
