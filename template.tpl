___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Simple encryption",
  "description": "A \u003cb\u003every\u003c/b\u003e simple \"encrypt\"/\"decrypt\" model for obfuscating strings. Does not require external resources. \u003cb\u003eNot safe for critical information, fairly easy to decode.\u003c/b\u003e",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "input",
    "displayName": "Input value",
    "simpleValueType": true,
    "alwaysInSummary": true
  },
  {
    "type": "TEXT",
    "name": "key",
    "displayName": "Encryption key",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "defaultValue": 42,
    "help": "Make it looooooong. The longer, the better. Like \u003cb\u003eminimum\u003c/b\u003e 32 characters long. But even longer is better.\u003cbr\u003e\u003cbr\u003e\n\nAim for \u003cmark\u003eSTRONG\u003c/mark\u003e on \u003ca href\u003d\"https://bitwarden.com/password-strength/#Password-Strength-Testing-Tool\" target\u003d\"_blank\"\u003eBitwarden\u0027s Password Strength Tester\u003c/a\u003e."
  },
  {
    "type": "RADIO",
    "name": "method",
    "displayName": "Method",
    "radioItems": [
      {
        "value": "encrypt",
        "displayValue": "Encrypt"
      },
      {
        "value": "decrypt",
        "displayValue": "Decrypt"
      }
    ],
    "simpleValueType": true,
    "defaultValue": "encrypt"
  }
]


___SANDBOXED_JS_FOR_SERVER___

const logToConsole = require("logToConsole");

const ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZÆØÅÄÖabcdefghijklmnopqrstuvwxyzæøåäö0123456789 .,!?()-–_~+|";
const MOD32 = 4294967296; // 2^32, replaces >>> 0

// Input validation
const original = data.input;
const key = data.key;
const method = data.method;

if (!original || !key || !method) {
  logToConsole("Missing required field(s): input, key, or method");
  return undefined;
}

function toUint32(n) {
  return ((n % MOD32) + MOD32) % MOD32;
}

function naiveHashKey(k) {
  let h = 0;
  for (let i = 0; i < k.length; i++) {
    let idx = ALPHABET.indexOf(k[i]);
    if (idx === -1) idx = 0;
    h = toUint32(h * 31 + idx);
  }
  return h;
}

function nextRandom(seed) {
  return toUint32(seed * 1664525 + 1013904223);
}

function generateShifts(k, length) {
  let seed = naiveHashKey(k);
  let shifts = [];
  for (let i = 0; i < length; i++) {
    seed = nextRandom(seed);
    shifts.push(seed % ALPHABET.length);
  }
  return shifts;
}

function encrypt(text, k) {
  let prngShifts = generateShifts(k, text.length);
  let output = "";
  for (let i = 0; i < text.length; i++) {
    let pos = ALPHABET.indexOf(text[i]);
    if (pos === -1) {
      output += text[i];
      continue;
    }
    let keyPos = ALPHABET.indexOf(k[i % k.length]);
    if (keyPos === -1) keyPos = 0;
    output += ALPHABET[(pos + keyPos + prngShifts[i]) % ALPHABET.length];
  }
  return output;
}

function decrypt(text, k) {
  let prngShifts = generateShifts(k, text.length);
  let output = "";
  for (let i = 0; i < text.length; i++) {
    let pos = ALPHABET.indexOf(text[i]);
    if (pos === -1) {
      output += text[i];
      continue;
    }
    let keyPos = ALPHABET.indexOf(k[i % k.length]);
    if (keyPos === -1) keyPos = 0;
    let newPos = pos - keyPos - prngShifts[i];
    while (newPos < 0) newPos += ALPHABET.length;
    output += ALPHABET[newPos];
  }
  return output;
}

if (method === "encrypt") {
  return encrypt(original, key);
} else if (method === "decrypt") {
  return decrypt(original, key);
} else {
  logToConsole("Invalid method: " + method + ". Use 'encrypt' or 'decrypt'.");
  return undefined;
}


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Encrypt
  code: |-
    const mockData = {
      // Mocked field values
      input: "taggingwise.com",
      method: "encrypt",
      key: "42"
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('wö!lfCw(Zu3Æ–Z.');
- name: Decrypt
  code: |-
    const mockData = {
      // Mocked field values
      input: "wö!lfCw(Zu3Æ–Z.",
      method: "decrypt",
      key: "42"
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo('taggingwise.com');


___NOTES___

Created on 16.3.2026, 15.37.15


