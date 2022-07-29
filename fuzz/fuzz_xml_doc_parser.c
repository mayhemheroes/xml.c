#include <stdio.h>
#include <stdlib.h> // malloc
#include <string.h> // memcpy
#include <xml.h>

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    // Create a non-const duplicate of fuzzer data
    uint8_t *xml_data = (uint8_t*) malloc(size);
    memcpy(xml_data, data, size);

    struct xml_document* document = xml_parse_document(xml_data, size);
    if (document)
        xml_document_free(document, false);
    return 0;
}
