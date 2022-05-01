global.window = global;

const bundle = require('rules_typescript_proto/test/test_es6_bundling/');

describe('Rollup', () => {
  it('should define Pizza with protobuf API', () => {
    expect(bundle.Pizza).toBeDefined();

    const pizza = new bundle.Pizza();
    pizza.setSize(bundle.PizzaSize.PIZZA_SIZE_LARGE);

    expect(pizza.getSize()).toBe(bundle.PizzaSize.PIZZA_SIZE_LARGE);
    expect(Array.isArray(pizza.getToppingIdsList())).toBe(true);
  });

  it('should define DeliveryPerson', () => {
    expect(bundle.DeliveryPerson).toBeDefined();
    expect(new bundle.DeliveryPerson()).toBeTruthy();
  });

  it('should define PizzaService', () => {
    expect(bundle.PizzaService).toBeDefined();
    expect(bundle.PizzaService.serviceName).toBe('test.bazel.proto.PizzaService');
    expect(bundle.PizzaService.OrderPizza.methodName).toBe('OrderPizza');
  });

  it('should define PizzaServiceClient', () => {
    expect(bundle.PizzaServiceClient).toBeDefined();
    const client = new bundle.PizzaServiceClient('http://localhost', {});
    expect(typeof client.orderPizza).toBe('function');
  });

  it('should follow expected naming styles', () => {
    expect(new bundle.alllowercase().setTest(1)).toBeTruthy();
    expect(new bundle.ALLUPPERCASE().setTest(1)).toBeTruthy();
    expect(new bundle.lowerCamelCase().setTest(1)).toBeTruthy();
    expect(new bundle.UpperCamelCase().setTest(1)).toBeTruthy();
    expect(new bundle.snake_case_snake_case().setTest(1)).toBeTruthy();
    expect(new bundle.Upper_snake_Case().setTest(1)).toBeTruthy();
    expect(new bundle.M2M().setTest(1)).toBeTruthy();
    expect(new bundle.M_2M().setTest(1)).toBeTruthy();
    expect(new bundle.M2_M().setTest(1)).toBeTruthy();
    expect(new bundle.M2M_().setTest(1)).toBeTruthy();
    expect(new bundle.m_22M().setTest(1)).toBeTruthy();
    expect(new bundle.m42_M().setTest(1)).toBeTruthy();
    expect(new bundle.m24M_().setTest(1)).toBeTruthy();
    expect(new bundle.M9().setTest(1)).toBeTruthy();
  });
});
