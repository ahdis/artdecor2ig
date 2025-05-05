rm log/*.log
rm data/bfs-country-codes.json
java -jar "/Users/oegger/.m2/repository/ca/uhn/hapi/fhir/org.hl7.fhir.validation.cli/6.5.17/org.hl7.fhir.validation.cli-6.5.17.jar" -factory ${PWD}/factories.json -version 4.0 -tx n/a