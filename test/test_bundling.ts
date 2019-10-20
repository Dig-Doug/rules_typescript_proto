import {DeliveryPerson} from 'rules_typescript_proto/test/proto/common/delivery_person_pb';
import {alllowercase, ALLUPPERCASE, lowerCamelCase, m24M_, M2_M, M2M, M2M_, m42_M, M9, m_22M, M_2M, snake_case_snake_case, Upper_snake_Case, UpperCamelCase,} from 'rules_typescript_proto/test/proto/naming_styles_pb';

const person = new DeliveryPerson();
console.log(person);

console.log(new alllowercase().setTest(1));
console.log(new ALLUPPERCASE().setTest(1));
console.log(new lowerCamelCase().setTest(1));
console.log(new UpperCamelCase().setTest(1));
console.log(new snake_case_snake_case().setTest(1));
console.log(new Upper_snake_Case().setTest(1));
console.log(new M2M().setTest(1));
console.log(new M_2M().setTest(1));
console.log(new M2_M().setTest(1));
console.log(new M2M_().setTest(1));
console.log(new m_22M().setTest(1));
console.log(new m42_M().setTest(1));
console.log(new m24M_().setTest(1));
console.log(new M9().setTest(1));
