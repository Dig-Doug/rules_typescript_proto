import deliveryPersonPb = require('rules_typescript_proto/test/proto/common/delivery_person_pb');
import {PizzaServiceClient} from 'rules_typescript_proto/test/proto/pizza_service_grpc_web_pb';

describe('CommonJs', () => {
  it('Loads imports using require()', () => {
    expect(deliveryPersonPb).toBeDefined();

    const person = new deliveryPersonPb.DeliveryPerson();
    person.setName('Doug');
    expect(person).toBeDefined();
  });

  it('Loads imports using TS from syntax', () => {
    expect(PizzaServiceClient).toBeDefined();
  });
});
