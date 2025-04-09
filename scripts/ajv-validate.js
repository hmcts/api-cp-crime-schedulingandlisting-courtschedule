// custom JSON schema validator
const fs = require("fs");
const path = require("path");
const Ajv = require("ajv/dist/2020").default;
const addFormats = require("ajv-formats");

const schemaPath = process.argv[2];
const dataPath = process.argv[3];

const schema = JSON.parse(fs.readFileSync(schemaPath, "utf-8"));
const data = JSON.parse(fs.readFileSync(dataPath, "utf-8"));

const ajv = new Ajv({
    strict: false,
    allErrors: true
});
addFormats(ajv); // addFormat support like "date-time"

const ajvValidate = ajv.compile(schema);
const valid = ajvValidate(data);

if (!valid) {
    console.error(`❌ Validation failed for ${dataPath}`);
    // console.error(ajvValidate.errors);

    for (const err of ajvValidate.errors) {
        const path = err.instancePath || err.dataPath || '';
        const schemaPath = err.schemaPath || '';
        const invalidValue = getValueAtPath(data, path);

        console.error(`❌ [${err.keyword}] ${err.message}`);
        console.error(`   → Schema        : ${schemaPath || '/'}`);
        console.error(`   → Path          : ${path || '/'}`);
        console.error(`   → Invalid value :`, invalidValue);
    }
    process.exit(1);

} else {
    console.log(`✅ ${dataPath} is valid!`);
}

// Helper to resolve deep value by JSON Pointer path
function getValueAtPath(obj, instancePath) {
    if (!instancePath) return obj;

    const parts = instancePath.split('/').filter(Boolean);
    return parts.reduce((o, key) => (o && key in o ? o[key] : undefined), obj);
}