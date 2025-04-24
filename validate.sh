

          for schemafile in $(find src/main/resources/openapi -name "*.json" ! -name "*.example.json"); do
            echo "schemafile=$schemafile"

            # Replace ".schema.json" with ".schema.example.json" to get the data file name
            datafile="${schemafile/.json/.example.json}"
            echo "datafile=$datafile"

            if [ -f "$datafile" ]; then
              echo "Validating $datafile against schema $schemafile"
              # strict mode is off because the "example" attribute is useful for openapi specs
              node scripts/ajv-validate.js "$schemafile" "$datafile" || exit 1
            else
              echo "⚠️ Skipping: no example file found for $schemafile"
            fi


openApiGenerate {
  generatorName = "spring"
  inputSpec = inputSpecFile.absolutePath
  outputDir = "$buildDir/generated"
  apiPackage = "uk.gov.hmcts.cp.openapi.api"
  modelPackage = "uk.gov.hmcts.cp.openapi.model"
  generateModelTests = true
  generateApiTests = true
  cleanupOutput = true
  configOptions = [
    dateLibrary                   : "java8",
    interfaceOnly                 : "true",
    hideGenerationTimestamp       : "true",
    useJakartaEe                  : "true",
    useBeanValidation             : "true",
    useTags                       : "true",
    useSpringBoot3                : "true",
    implicitHeaders               : "false",
    performBeanValidation         : "true",
    additionalModelTypeAnnotations: "@lombok.Builder;@lombok.AllArgsConstructor;@lombok.NoArgsConstructor",
    serializableModel             : "true",
    openApiNullable               : "false"
  ]
}
