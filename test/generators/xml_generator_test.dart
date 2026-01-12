import 'package:test/test.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

void main() {
  group('XmlLayoutGenerator', () {
    const generator = XmlLayoutGenerator();

    group('basic generation', () {
      test('generates empty output for empty data', () {
        final result = generator.generate({});
        expect(result, isEmpty);
      });

      test('generates simple element with text', () {
        final data = {'root': 'Hello World'};
        final result = generator.generate(data);
        expect(result, contains('<root>Hello World</root>'));
      });

      test('generates element with numeric value', () {
        final data = {'count': 42};
        final result = generator.generate(data);
        expect(result, contains('<count>42</count>'));
      });

      test('generates element with boolean true', () {
        final data = {'active': true};
        final result = generator.generate(data);
        expect(result, contains('<active>true</active>'));
      });

      test('generates element with boolean false', () {
        final data = {'deleted': false};
        final result = generator.generate(data);
        expect(result, contains('<deleted>false</deleted>'));
      });

      test('generates element with double value', () {
        final data = {'price': 9.99};
        final result = generator.generate(data);
        expect(result, contains('<price>9.99</price>'));
      });

      test('generates empty element for null value', () {
        final data = {'empty': null};
        final result = generator.generate(data);
        expect(result, contains('<empty/>'));
      });
    });

    group('attributes', () {
      test('generates element with single attribute', () {
        final data = {'user': 'John'};
        final keyMeta = {
          'user': {
            'xmlMeta': {
              'attributes': {'id': '123'},
              'isCdata': false,
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('id="123"'));
        expect(result, contains('John'));
      });

      test('generates element with multiple attributes', () {
        final data = {'user': 'John'};
        final keyMeta = {
          'user': {
            'xmlMeta': {
              'attributes': {'id': '123', 'active': 'true'},
              'isCdata': false,
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('id="123"'));
        expect(result, contains('active="true"'));
      });

      test('generates nested element with attributes', () {
        final data = {
          'root': {
            'user': {'name': 'John'},
          },
        };
        final keyMeta = {
          'root': {
            'children': {
              'user': {
                'xmlMeta': {
                  'attributes': {'role': 'admin'},
                  'isCdata': false,
                },
              },
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('role="admin"'));
        expect(result, contains('<name>John</name>'));
      });
    });

    group('CDATA sections', () {
      test('generates CDATA content', () {
        final data = {'bio': 'Special <characters> allowed'};
        final keyMeta = {
          'bio': {
            'xmlMeta': {
              'isCdata': true,
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('<![CDATA[Special <characters> allowed]]>'));
      });

      test('generates CDATA with XML-like content', () {
        final data = {'code': '<div>HTML content</div>'};
        final keyMeta = {
          'code': {
            'xmlMeta': {
              'isCdata': true,
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('<![CDATA[<div>HTML content</div>]]>'));
      });

      test('generates nested element with CDATA', () {
        final data = {
          'root': {
            'description': 'Some <special> content',
          },
        };
        final keyMeta = {
          'root': {
            'children': {
              'description': {
                'xmlMeta': {
                  'isCdata': true,
                },
              },
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('<![CDATA[Some <special> content]]>'));
      });
    });

    group('comments', () {
      test('generates comment before element', () {
        final data = {
          'root': {
            'preferences': 'dark',
          },
        };
        final keyMeta = {
          'root': {
            'children': {
              'preferences': {
                'xmlMeta': {
                  'comment': 'User preferences',
                  'isCdata': false,
                },
              },
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('<!--User preferences-->'));
        expect(result, contains('<preferences>dark</preferences>'));
      });

      test('generates comment before nested element', () {
        final data = {
          'root': {
            'section': {'title': 'Main'},
          },
        };
        final keyMeta = {
          'root': {
            'children': {
              'section': {
                'xmlMeta': {
                  'comment': 'Important section',
                  'isCdata': false,
                },
              },
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('<!--Important section-->'));
        expect(result, contains('<section>'));
      });
    });

    group('namespaces', () {
      test('generates element with default namespace', () {
        final data = {
          'root': {'item': 'value'},
        };
        final keyMeta = {
          'root': {
            'xmlMeta': {
              'namespace': 'http://example.com',
              'isCdata': false,
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('xmlns="http://example.com"'));
      });

      test('generates element with prefixed namespace', () {
        final data = {
          'root': {'item': 'value'},
        };
        final keyMeta = {
          'root': {
            'xmlMeta': {
              'prefix': 'app',
              'namespace': 'http://example.com/app',
              'isCdata': false,
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('app:root'));
        expect(result, contains('xmlns:app="http://example.com/app"'));
      });

      test('generates nested element with prefix', () {
        final data = {
          'root': {
            'section': {
              'value': 'content',
            },
          },
        };
        final keyMeta = {
          'root': {
            'children': {
              'section': {
                'xmlMeta': {
                  'prefix': 'app',
                  'namespace': 'http://example.com/app',
                  'isCdata': false,
                },
                'children': {
                  'value': {
                    'xmlMeta': {
                      'prefix': 'data',
                      'namespace': 'http://example.com/data',
                      'isCdata': false,
                    },
                  },
                },
              },
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('app:section'));
        expect(result, contains('data:value'));
      });
    });

    group('nested structures', () {
      test('generates nested elements', () {
        final data = {
          'user': {
            'name': 'John Doe',
            'email': 'john@example.com',
          },
        };
        final result = generator.generate(data);
        expect(result, contains('<name>John Doe</name>'));
        expect(result, contains('<email>john@example.com</email>'));
      });

      test('generates deeply nested elements', () {
        final data = {
          'root': {
            'level1': {
              'level2': {
                'level3': 'deep value',
              },
            },
          },
        };
        final result = generator.generate(data);
        expect(result, contains('<level3>deep value</level3>'));
      });

      test('generates sibling elements', () {
        final data = {
          'root': {
            'first': 1,
            'second': 2,
            'third': 3,
          },
        };
        final result = generator.generate(data);
        expect(result, contains('<first>1</first>'));
        expect(result, contains('<second>2</second>'));
        expect(result, contains('<third>3</third>'));
      });
    });

    group('lists (repeated elements)', () {
      test('generates repeated elements from list', () {
        final data = {
          'root': {
            'item': ['a', 'b', 'c'],
          },
        };
        final result = generator.generate(data);
        expect(result, contains('<item>a</item>'));
        expect(result, contains('<item>b</item>'));
        expect(result, contains('<item>c</item>'));
      });

      test('generates repeated elements with numeric values', () {
        final data = {
          'root': {
            'number': [1, 2, 3],
          },
        };
        final result = generator.generate(data);
        expect(result, contains('<number>1</number>'));
        expect(result, contains('<number>2</number>'));
        expect(result, contains('<number>3</number>'));
      });

      test('generates repeated complex elements', () {
        final data = {
          'root': {
            'user': [
              {'name': 'John'},
              {'name': 'Jane'},
            ],
          },
        };
        final result = generator.generate(data);
        expect(result, contains('<user>'));
        expect(result, contains('<name>John</name>'));
        expect(result, contains('<name>Jane</name>'));
      });

      test('preserves metadata for list items', () {
        final data = {
          'root': {
            'item': ['first', 'second'],
          },
        };
        final keyMeta = {
          'root': {
            'children': {
              'item.0': {
                'xmlMeta': {
                  'attributes': {'id': '1'},
                  'isCdata': false,
                },
              },
              'item.1': {
                'xmlMeta': {
                  'attributes': {'id': '2'},
                  'isCdata': false,
                },
              },
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('id="1"'));
        expect(result, contains('id="2"'));
      });
    });

    group('mixed content', () {
      test('handles text with elements', () {
        final data = {
          'root': {
            '_text': 'Some text',
            'child': 'nested',
          },
        };
        final result = generator.generate(data);
        expect(result, contains('Some text'));
        expect(result, contains('<child>nested</child>'));
      });
    });

    group('formatting', () {
      test('generates pretty printed output by default', () {
        final data = {
          'root': {
            'child': 'value',
          },
        };
        final result = generator.generate(data);
        expect(result, contains('\n'));
      });

      test('generates compact output when prettyPrint is false', () {
        final data = {
          'root': {
            'child': 'value',
          },
        };
        final result = generator.generate(data, prettyPrint: false);
        expect(result.contains('\n'), isFalse);
      });
    });

    group('edge cases', () {
      test('handles special characters in text', () {
        final data = {'root': '<script>alert()</script>'};
        final result = generator.generate(data);
        // XML builder escapes < and > characters
        expect(result, contains('&lt;script'));
        expect(result, contains('&lt;/script'));
      });

      test('handles unicode content', () {
        final data = {'root': 'Hello World'};
        final result = generator.generate(data);
        expect(result, contains('Hello World'));
      });

      test('handles attributes with colons', () {
        final data = {'root': 'Content'};
        final keyMeta = {
          'root': {
            'xmlMeta': {
              'attributes': {'xml:lang': 'en'},
              'isCdata': false,
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('xml:lang="en"'));
      });

      test('handles missing keyMeta gracefully', () {
        final data = {'root': 'Content'};
        final result = generator.generate(data);
        expect(result, contains('<root>Content</root>'));
      });
    });
  });

  group('jsonToXml with preserveLayout', () {
    test('uses generator when keyMeta and preserveLayout are set', () {
      final data = {'user': 'John'};
      final keyMeta = {
        'user': {
          'xmlMeta': {
            'attributes': {'id': '123'},
            'isCdata': false,
          },
        },
      };
      final result = jsonToXml(data, keyMeta: keyMeta);
      expect(result, contains('id="123"'));
      expect(result, contains('John'));
    });

    test('falls back to default behavior when preserveLayout is false', () {
      final data = {'name': 'John'};
      final keyMeta = {
        'name': {
          'xmlMeta': {
            'attributes': {'id': '123'},
            'isCdata': false,
          },
        },
      };
      final result = jsonToXml(data, keyMeta: keyMeta, preserveLayout: false);
      // Default behavior wraps in root element
      expect(result, contains('<root>'));
      expect(result, contains('<name>John</name>'));
    });

    test('falls back to default behavior when keyMeta is null', () {
      final data = {'name': 'John'};
      final result = jsonToXml(data);
      expect(result, contains('<root>'));
      expect(result, contains('<name>John</name>'));
    });

    test('backward compatibility - basic XML generation', () {
      final result = jsonToXml({'name': 'John', 'age': 30});
      expect(result, contains('<name>John</name>'));
      expect(result, contains('<age>30</age>'));
    });

    test('backward compatibility - nested structures', () {
      final result = jsonToXml({
        'user': {'name': 'John'}
      });
      expect(result, contains('<user>'));
      expect(result, contains('<name>John</name>'));
    });

    test('backward compatibility - list values', () {
      final result = jsonToXml({
        'item': ['a', 'b']
      });
      expect(result, contains('<item>a</item>'));
      expect(result, contains('<item>b</item>'));
    });
  });

  group('round-trip tests', () {
    const parser = XmlLayoutParser();
    const generator = XmlLayoutGenerator();

    test('attributes round-trip', () {
      const original = '<user id="123" active="true">John</user>';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('id="123"'));
      expect(generated, contains('active="true"'));
      expect(generated, contains('John'));
    });

    test('CDATA round-trip', () {
      const original = '<bio><![CDATA[Special <content>]]></bio>';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('<![CDATA[Special <content>]]>'));
    });

    test('namespace round-trip', () {
      const original =
          '<app:root xmlns:app="http://example.com/app"><app:item>value</app:item></app:root>';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('app:root'));
      expect(generated, contains('xmlns:app="http://example.com/app"'));
    });

    test('comment round-trip', () {
      const original = '<root><!--Important--><item>value</item></root>';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('<!--Important-->'));
      expect(generated, contains('<item>value</item>'));
    });

    test('nested elements round-trip', () {
      const original = '''<user>
  <name>John Doe</name>
  <email>john@example.com</email>
</user>''';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('<name>John Doe</name>'));
      expect(generated, contains('<email>john@example.com</email>'));
    });

    test('list elements round-trip', () {
      const original = '''<root>
  <item>a</item>
  <item>b</item>
  <item>c</item>
</root>''';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('<item>a</item>'));
      expect(generated, contains('<item>b</item>'));
      expect(generated, contains('<item>c</item>'));
    });

    test('complex document round-trip', () {
      const original = '''<user id="123">
  <name>John Doe</name>
  <bio><![CDATA[Bio with <special> chars]]></bio>
  <!--Preferences section-->
  <preferences xmlns:app="http://example.com">
    <app:theme>dark</app:theme>
  </preferences>
</user>''';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );

      // Verify all elements are preserved
      expect(generated, contains('id="123"'));
      expect(generated, contains('<name>John Doe</name>'));
      expect(generated, contains('<![CDATA[Bio with <special> chars]]>'));
      expect(generated, contains('<!--Preferences section-->'));
      expect(generated, contains('app:theme'));
    });

    test('list with attributes round-trip', () {
      const original = '''<root>
  <item id="1">first</item>
  <item id="2">second</item>
</root>''';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('id="1"'));
      expect(generated, contains('id="2"'));
      expect(generated, contains('first'));
      expect(generated, contains('second'));
    });

    test('boolean values round-trip', () {
      const original =
          '<settings><enabled>true</enabled><debug>false</debug></settings>';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('<enabled>true</enabled>'));
      expect(generated, contains('<debug>false</debug>'));
    });

    test('numeric values round-trip', () {
      const original = '<data><count>42</count><price>9.99</price></data>';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('<count>42</count>'));
      expect(generated, contains('<price>9.99</price>'));
    });
  });

  group('edge cases', () {
    const generator = XmlLayoutGenerator();

    test('handles null values gracefully', () {
      final data = {'root': null};
      final result = generator.generate(data);
      expect(result, isNotNull);
    });

    test('handles empty string values', () {
      final data = {'root': ''};
      final result = generator.generate(data);
      // XML builder produces empty element with opening/closing tags
      expect(result, contains('<root></root>'));
    });

    test('handles empty map values', () {
      final data = {'root': <String, dynamic>{}};
      final result = generator.generate(data);
      expect(result, contains('<root/>'));
    });

    test('handles empty list values', () {
      final data = {
        'root': {'items': <String>[]},
      };
      final result = generator.generate(data);
      expect(result, contains('<root/>'));
    });

    test('handles deeply nested structures', () {
      final data = {
        'a': {
          'b': {
            'c': {
              'd': {
                'e': 'deep value',
              },
            },
          },
        },
      };
      final result = generator.generate(data);
      expect(result, contains('<e>deep value</e>'));
    });

    test('handles special XML characters in attribute values', () {
      final data = {'root': 'content'};
      final keyMeta = {
        'root': {
          'xmlMeta': {
            'attributes': {'data': 'value with "quotes"'},
            'isCdata': false,
          },
        },
      };
      final result = generator.generate(data, keyMeta: keyMeta);
      expect(result, contains('data='));
    });
  });
}
