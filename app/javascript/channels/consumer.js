// Crea un único consumer para toda la app
import { createConsumer } from "@rails/actioncable"

export default createConsumer("/cable")
