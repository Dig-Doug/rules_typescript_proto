import {Timestamp} from 'google-protobuf/google/protobuf/timestamp_pb';
import * as deliveryPersonPb from 'rules_typescript_proto/test/proto/common/delivery_person_pb';
import {PizzaService} from 'rules_typescript_proto/test/proto/pizza_service_pb_service';

describe('CommonJs', () => {
  it('Loads imports using require()', () => {
    expect(deliveryPersonPb).toBeDefined();

    const person = new deliveryPersonPb.DeliveryPerson();
    person.setName('Doug');
    const lastDeliveryTime = new Timestamp();
    lastDeliveryTime.fromDate(new Date());
    person.setLastDeliveryTime(lastDeliveryTime);
    expect(person).toBeDefined();
  });

  it('Loads imports using TS from syntax', () => {
    expect(PizzaService).toBeDefined();
  });
});
