#import "GRXJSONCleaner.h"

@implementation GRXJSONCleaner

static const int EncLen_UTF8[256] = {
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 1, 1
};

static inline void copyUTF8CharacterAndAdvancePointers(UTF8Char **source, UTF8Char **target) {
    UTF8Char character = **source;
    if (__builtin_expect(character < 128, 1)) {
        // one byte UTF-8 character
        **target = **source;
        *source += 1;
        *target += 1;
    } else {
        int len = EncLen_UTF8[character];
        memcpy(*target, *source, len);
        *source += len;
        *target += len;
    }
}

static inline void skipUTF8Character(UTF8Char **source) {
    *source += EncLen_UTF8[**source];
}

+ (NSData *)cleanJSONDataWithData:(NSData *)data {
    UTF8Char *originalString = (UTF8Char *)[data bytes];
    NSUInteger length = [data length];

    UTF8Char *modifiedString = malloc(sizeof(UTF8Char) * length);

    UTF8Char *originalStringCurrent = originalString;
    UTF8Char *originalStringEnd = originalString + length;
    UTF8Char *modifiedStringCurrent = modifiedString;

    while (originalStringCurrent < originalStringEnd) {
        UTF8Char currentChar = *originalStringCurrent;

        if (currentChar == '\t' || currentChar == ' ' || currentChar == '\r'
            || currentChar == '\n') {
            // skip whitespace

            // Ignore whitespace tokens. According to ES 5.1 section 15.12.1.1,
            // whitespace tokens include tabs, carriage returns, line feeds, and
            // space characters.
            originalStringCurrent++;
        } else if (currentChar == '"') {
            // we found a string! -> handle it
            *modifiedStringCurrent++ = currentChar;
            originalStringCurrent++;

            UTF8Char lastChar = 0;

            while (originalStringCurrent < originalStringEnd) {
                currentChar = *originalStringCurrent;

                if (currentChar == '"') {
                    *modifiedStringCurrent++ = currentChar;
                    originalStringCurrent++;

                    if (lastChar == '\\') {
                        // was escaped character -> not at string end
                    } else {
                        // arrived at end of string
                        break;
                    }
                } else if (currentChar == '\n' || currentChar == '\r') {
                    // line breaks should not happen in JSON strings!
                    *modifiedStringCurrent++ = currentChar;
                    originalStringCurrent++;
                    break;
                } else {
                    // still in string -> copy character
                    copyUTF8CharacterAndAdvancePointers(&originalStringCurrent,
                                                        &modifiedStringCurrent);
                }
                lastChar = currentChar;
            }
        } else if (currentChar == '/' && originalStringCurrent + 1 < originalStringEnd) {
            // maybe we have a single-line or multi-line comment
            UTF8Char nextChar = *(originalStringCurrent + 1);

            if (nextChar == '/') {
                // single line comment
                originalStringCurrent += 2;

                while (originalStringCurrent < originalStringEnd) {
                    char currentChar = *originalStringCurrent;

                    if (currentChar == '\r' || currentChar == '\n') {
                        // at end of line -> comment end
                        break;
                    } else {
                        // skip
                        skipUTF8Character(&originalStringCurrent);
                    }
                }
            } else if (nextChar == '*') {
                // multi line comment
                originalStringCurrent += 2;

                while (originalStringCurrent < originalStringEnd) {
                    char currentChar = *originalStringCurrent;

                    if (currentChar == '*') {
                        originalStringCurrent++;

                        if (originalStringCurrent < originalStringEnd) {
                            currentChar = *originalStringCurrent;
                            if (currentChar == '/') {
                                // comment end!
                                originalStringCurrent++;
                                break;
                            }
                        }
                    } else {
                        // skip
                        skipUTF8Character(&originalStringCurrent);
                    }
                }
            } else {
                // nope, no comment, just copy the character
                *modifiedStringCurrent++ = currentChar;
                originalStringCurrent++;
            }
        } else {
            // copy character as is
            copyUTF8CharacterAndAdvancePointers(&originalStringCurrent, &modifiedStringCurrent);
        }
    }

    NSUInteger modifiedStringLength = modifiedStringCurrent - modifiedString;

    if (modifiedStringLength != length) {
        modifiedString = realloc(modifiedString, sizeof(UTF8Char) * modifiedStringLength);
        return [NSData dataWithBytesNoCopy:modifiedString
                                    length:modifiedStringLength
                              freeWhenDone:YES];
    } else {
        free(modifiedString);
        return data;
    }
}


@end
