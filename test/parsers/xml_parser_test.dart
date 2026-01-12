import 'package:test/test.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

void main() {
  group('XmlLayoutParser', () {
    const parser = XmlLayoutParser();

    group('empty and basic documents', () {
      test('parses empty string', () {
        final result = parser.parse('');
        expect(result.data, isEmpty);
        expect(result.keyMeta, isNull);
      });

      test('parses simple element with text', () {
        final result = parser.parse('<root>Hello World</root>');
        expect(result.data['root'], 'Hello World');
      });

      test('parses element with numeric text', () {
        final result = parser.parse('<count>42</count>');
        expect(result.data['count'], 42);
      });

      test('parses element with boolean true', () {
        final result = parser.parse('<active>true</active>');
        expect(result.data['active'], true);
      });

      test('parses element with boolean false', () {
        final result = parser.parse('<deleted>false</deleted>');
        expect(result.data['deleted'], false);
      });

      test('parses element with double value', () {
        final result = parser.parse('<price>9.99</price>');
        expect(result.data['price'], 9.99);
      });

      test('parses empty element as null', () {
        final result = parser.parse('<empty></empty>');
        expect(result.data['empty'], isNull);
      });
    });

    group('attributes', () {
      test('extracts single attribute', () {
        final result = parser.parse('<user id="123">John</user>');
        expect(result.data['user'], 'John');
        expect(result.keyMeta, isNotNull);
        expect(result.keyMeta!['user']['xmlMeta']['attributes']['id'], '123');
      });

      test('extracts multiple attributes', () {
        final result = parser.parse('<user id="123" active="true">John</user>');
        expect(result.data['user'], 'John');
        expect(result.keyMeta!['user']['xmlMeta']['attributes']['id'], '123');
        expect(
            result.keyMeta!['user']['xmlMeta']['attributes']['active'], 'true');
      });

      test('attributes on nested elements', () {
        final result = parser.parse('''
          <root>
            <user role="admin">
              <name>John</name>
            </user>
          </root>
        ''');
        expect(result.data['root']['user']['name'], 'John');
        expect(
            result.keyMeta!['root']['children']['user']['xmlMeta']['attributes']
                ['role'],
            'admin');
      });

      test('attributes with special characters in values', () {
        final result =
            parser.parse('<item data-value="test&amp;value">Content</item>');
        expect(result.data['item'], 'Content');
        expect(result.keyMeta!['item']['xmlMeta']['attributes']['data-value'],
            'test&value');
      });
    });

    group('CDATA sections', () {
      test('parses CDATA content', () {
        final result =
            parser.parse('<bio><![CDATA[Special <characters> allowed]]></bio>');
        expect(result.data['bio'], 'Special <characters> allowed');
        expect(result.keyMeta!['bio']['xmlMeta']['isCdata'], true);
      });

      test('parses CDATA with XML-like content', () {
        final result =
            parser.parse('<code><![CDATA[<div>HTML content</div>]]></code>');
        expect(result.data['code'], '<div>HTML content</div>');
        expect(result.keyMeta!['code']['xmlMeta']['isCdata'], true);
      });

      test('parses CDATA with multiple sections', () {
        final result = parser
            .parse('<content><![CDATA[Part 1]]><![CDATA[ Part 2]]></content>');
        expect(result.data['content'], 'Part 1 Part 2');
        expect(result.keyMeta!['content']['xmlMeta']['isCdata'], true);
      });

      test('nested element with CDATA', () {
        final result = parser.parse('''
          <root>
            <description><![CDATA[Some <special> content]]></description>
          </root>
        ''');
        expect(result.data['root']['description'], 'Some <special> content');
        expect(
            result.keyMeta!['root']['children']['description']['xmlMeta']
                ['isCdata'],
            true);
      });
    });

    group('comments', () {
      test('captures preceding comment', () {
        final result = parser.parse('''
          <root>
            <!-- User preferences -->
            <preferences>dark</preferences>
          </root>
        ''');
        expect(result.data['root']['preferences'], 'dark');
        expect(
            result.keyMeta!['root']['children']['preferences']['xmlMeta']
                ['comment'],
            'User preferences');
      });

      test('captures comment before nested element', () {
        final result = parser.parse('''
          <root>
            <!-- Important section -->
            <section>
              <title>Main</title>
            </section>
          </root>
        ''');
        expect(result.data['root']['section']['title'], 'Main');
        expect(
            result.keyMeta!['root']['children']['section']['xmlMeta']
                ['comment'],
            'Important section');
      });

      test('ignores comments not immediately before element', () {
        final result = parser.parse('''
          <root>
            <!-- First comment -->
            <other>value</other>
            <!-- Second comment is for target -->
            <target>content</target>
          </root>
        ''');
        expect(result.data['root']['target'], 'content');
        expect(
            result.keyMeta!['root']['children']['target']['xmlMeta']['comment'],
            'Second comment is for target');
      });
    });

    group('namespaces', () {
      test('captures namespace URI', () {
        final result = parser.parse(
            '<root xmlns="http://example.com"><item>value</item></root>');
        expect(result.data['root']['item'], 'value');
        expect(result.keyMeta!['root']['xmlMeta']['namespace'],
            'http://example.com');
      });

      test('captures namespace prefix', () {
        final result = parser.parse(
            '<app:root xmlns:app="http://example.com/app"><app:item>value</app:item></app:root>');
        expect(result.data['root']['item'], 'value');
        expect(result.keyMeta!['root']['xmlMeta']['prefix'], 'app');
        expect(result.keyMeta!['root']['xmlMeta']['namespace'],
            'http://example.com/app');
      });

      test('nested elements with different namespaces', () {
        final result = parser.parse('''
          <root xmlns:app="http://example.com/app" xmlns:data="http://example.com/data">
            <app:section>
              <data:value>content</data:value>
            </app:section>
          </root>
        ''');
        expect(result.data['root']['section']['value'], 'content');
        expect(
            result.keyMeta!['root']['children']['section']['xmlMeta']['prefix'],
            'app');
        expect(
            result.keyMeta!['root']['children']['section']['children']['value']
                ['xmlMeta']['prefix'],
            'data');
      });
    });

    group('nested structures', () {
      test('parses nested elements', () {
        final result = parser.parse('''
          <user>
            <name>John Doe</name>
            <email>john@example.com</email>
          </user>
        ''');
        expect(result.data['user']['name'], 'John Doe');
        expect(result.data['user']['email'], 'john@example.com');
      });

      test('parses deeply nested elements', () {
        final result = parser.parse('''
          <root>
            <level1>
              <level2>
                <level3>deep value</level3>
              </level2>
            </level1>
          </root>
        ''');
        expect(result.data['root']['level1']['level2']['level3'], 'deep value');
      });

      test('parses sibling elements', () {
        final result = parser.parse('''
          <root>
            <first>1</first>
            <second>2</second>
            <third>3</third>
          </root>
        ''');
        expect(result.data['root']['first'], 1);
        expect(result.data['root']['second'], 2);
        expect(result.data['root']['third'], 3);
      });
    });

    group('lists (repeated elements)', () {
      test('parses repeated elements as list', () {
        final result = parser.parse('''
          <root>
            <item>a</item>
            <item>b</item>
            <item>c</item>
          </root>
        ''');
        expect(result.data['root']['item'], ['a', 'b', 'c']);
      });

      test('parses repeated elements with numeric values', () {
        final result = parser.parse('''
          <root>
            <number>1</number>
            <number>2</number>
            <number>3</number>
          </root>
        ''');
        expect(result.data['root']['number'], [1, 2, 3]);
      });

      test('parses repeated complex elements', () {
        final result = parser.parse('''
          <root>
            <user>
              <name>John</name>
            </user>
            <user>
              <name>Jane</name>
            </user>
          </root>
        ''');
        expect(result.data['root']['user'], [
          {'name': 'John'},
          {'name': 'Jane'},
        ]);
      });

      test('preserves metadata for list items', () {
        final result = parser.parse('''
          <root>
            <item id="1">first</item>
            <item id="2">second</item>
          </root>
        ''');
        expect(result.data['root']['item'], ['first', 'second']);
        expect(
            result.keyMeta!['root']['children']['item.0']['xmlMeta']
                ['attributes']['id'],
            '1');
        expect(
            result.keyMeta!['root']['children']['item.1']['xmlMeta']
                ['attributes']['id'],
            '2');
      });
    });

    group('mixed content', () {
      test('handles text with elements', () {
        final result =
            parser.parse('<root>Some text <child>nested</child></root>');
        expect(result.data['root']['_text'], 'Some text');
        expect(result.data['root']['child'], 'nested');
      });

      test('handles multiple text nodes', () {
        final result =
            parser.parse('<root>Start <middle>value</middle> End</root>');
        expect(result.data['root']['_text'], 'Start End');
        expect(result.data['root']['middle'], 'value');
      });
    });

    group('error handling', () {
      test('throws FormatException on invalid XML', () {
        expect(
          () => parser.parse('<invalid>'),
          throwsA(isA<FormatException>()),
        );
      });

      test('throws FormatException on mismatched tags', () {
        expect(
          () => parser.parse('<open>content</close>'),
          throwsA(isA<FormatException>()),
        );
      });

      test('throws FormatException on malformed XML', () {
        expect(
          () => parser.parse('not xml at all'),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('complex documents', () {
      test('parses document with attributes, CDATA, comments, and namespaces',
          () {
        final xml = '''
          <user id="123" active="true">
            <name>John Doe</name>
            <bio><![CDATA[Special <characters> allowed]]></bio>
            <!-- User preferences -->
            <preferences xmlns:app="http://example.com">
              <app:theme>dark</app:theme>
            </preferences>
          </user>
        ''';
        final result = parser.parse(xml);

        // Data extraction
        expect(result.data['user']['name'], 'John Doe');
        expect(result.data['user']['bio'], 'Special <characters> allowed');
        expect(result.data['user']['preferences']['theme'], 'dark');

        // Metadata extraction
        expect(result.keyMeta!['user']['xmlMeta']['attributes']['id'], '123');
        expect(
            result.keyMeta!['user']['xmlMeta']['attributes']['active'], 'true');
        expect(result.keyMeta!['user']['children']['bio']['xmlMeta']['isCdata'],
            true);
        expect(
            result.keyMeta!['user']['children']['preferences']['xmlMeta']
                ['comment'],
            'User preferences');
        expect(
            result.keyMeta!['user']['children']['preferences']['children']
                ['theme']['xmlMeta']['prefix'],
            'app');
      });

      test('parses document with multiple lists', () {
        final xml = '''
          <catalog>
            <book>
              <title>Book One</title>
              <author>Author A</author>
            </book>
            <book>
              <title>Book Two</title>
              <author>Author B</author>
            </book>
            <category>Fiction</category>
            <category>Drama</category>
          </catalog>
        ''';
        final result = parser.parse(xml);

        expect(result.data['catalog']['book'], [
          {'title': 'Book One', 'author': 'Author A'},
          {'title': 'Book Two', 'author': 'Author B'},
        ]);
        expect(result.data['catalog']['category'], ['Fiction', 'Drama']);
      });
    });

    group('edge cases', () {
      test('handles whitespace-only text content', () {
        final result = parser.parse('<root>   </root>');
        expect(result.data['root'], isNull);
      });

      test('handles self-closing tags', () {
        final result = parser.parse('<root><empty/></root>');
        expect(result.data['root']['empty'], isNull);
      });

      test('handles special characters in text', () {
        final result =
            parser.parse('<root>&lt;script&gt;alert()&lt;/script&gt;</root>');
        expect(result.data['root'], '<script>alert()</script>');
      });

      test('handles unicode content', () {
        final result = parser.parse('<root>日本語テスト</root>');
        expect(result.data['root'], '日本語テスト');
      });

      test('handles emoji content', () {
        final result = parser.parse('<root>Hello 🎉</root>');
        expect(result.data['root'], 'Hello 🎉');
      });

      test('handles attributes with colons', () {
        final result = parser.parse('<root xml:lang="en">Content</root>');
        expect(result.data['root'], 'Content');
        expect(
            result.keyMeta!['root']['xmlMeta']['attributes']['xml:lang'], 'en');
      });
    });
  });

  group('xmlToJson with preserveLayout', () {
    test('returns Map when preserveLayout is false', () {
      final result = xmlToJson('<root><name>test</name></root>');
      expect(result, isA<Map<String, dynamic>>());
    });

    test('returns LayoutAwareParseResult when preserveLayout is true', () {
      final result =
          xmlToJson('<root><name>test</name></root>', preserveLayout: true);
      expect(result, isA<LayoutAwareParseResult>());
    });

    test('backward compatibility - basic XML parsing', () {
      final result = xmlToJson('<root><name>John</name><age>30</age></root>');
      expect(result['name'], 'John');
      expect(result['age'], 30);
    });

    test('backward compatibility - nested structures', () {
      final result = xmlToJson('<root><user><name>John</name></user></root>');
      expect(result['user']['name'], 'John');
    });

    test('backward compatibility - repeated elements as list', () {
      final result = xmlToJson('<root><item>a</item><item>b</item></root>');
      expect(result['item'], ['a', 'b']);
    });

    test('preserveLayout extracts attribute metadata', () {
      final result =
          xmlToJson('<user id="123">John</user>', preserveLayout: true)
              as LayoutAwareParseResult;
      expect(result.data['user'], 'John');
      expect(result.keyMeta!['user']['xmlMeta']['attributes']['id'], '123');
    });

    test('preserveLayout extracts CDATA metadata', () {
      final result =
          xmlToJson('<bio><![CDATA[Content]]></bio>', preserveLayout: true)
              as LayoutAwareParseResult;
      expect(result.data['bio'], 'Content');
      expect(result.keyMeta!['bio']['xmlMeta']['isCdata'], true);
    });

    test('preserveLayout extracts namespace metadata', () {
      final result = xmlToJson(
          '<root xmlns="http://example.com"><item>value</item></root>',
          preserveLayout: true) as LayoutAwareParseResult;
      expect(result.data['root']['item'], 'value');
      expect(result.keyMeta!['root']['xmlMeta']['namespace'],
          'http://example.com');
    });

    test('preserveLayout extracts comment metadata', () {
      final result = xmlToJson(
          '<root><!-- comment --><item>value</item></root>',
          preserveLayout: true) as LayoutAwareParseResult;
      expect(result.data['root']['item'], 'value');
      expect(result.keyMeta!['root']['children']['item']['xmlMeta']['comment'],
          'comment');
    });
  });

  group('round-trip tests', () {
    test('attributes round-trip', () {
      const original = '<user id="123" active="true">John</user>';
      final result =
          xmlToJson(original, preserveLayout: true) as LayoutAwareParseResult;
      expect(result.keyMeta!['user']['xmlMeta']['attributes']['id'], '123');
      expect(
          result.keyMeta!['user']['xmlMeta']['attributes']['active'], 'true');
    });

    test('CDATA round-trip', () {
      const original = '<bio><![CDATA[Special <content>]]></bio>';
      final result =
          xmlToJson(original, preserveLayout: true) as LayoutAwareParseResult;
      expect(result.keyMeta!['bio']['xmlMeta']['isCdata'], true);
    });

    test('namespace round-trip', () {
      const original =
          '<app:root xmlns:app="http://example.com/app"><app:item>value</app:item></app:root>';
      final result =
          xmlToJson(original, preserveLayout: true) as LayoutAwareParseResult;
      expect(result.keyMeta!['root']['xmlMeta']['prefix'], 'app');
      expect(result.keyMeta!['root']['xmlMeta']['namespace'],
          'http://example.com/app');
    });

    test('comment round-trip', () {
      const original = '<root><!-- Important --><item>value</item></root>';
      final result =
          xmlToJson(original, preserveLayout: true) as LayoutAwareParseResult;
      expect(result.keyMeta!['root']['children']['item']['xmlMeta']['comment'],
          'Important');
    });

    test('complex document round-trip', () {
      const original = '''
        <user id="123">
          <name>John Doe</name>
          <bio><![CDATA[Bio with <special> chars]]></bio>
          <!-- Preferences section -->
          <preferences xmlns:app="http://example.com">
            <app:theme>dark</app:theme>
          </preferences>
        </user>
      ''';
      final result =
          xmlToJson(original, preserveLayout: true) as LayoutAwareParseResult;

      // Verify all metadata is captured
      expect(result.keyMeta!['user']['xmlMeta']['attributes']['id'], '123');
      expect(result.keyMeta!['user']['children']['bio']['xmlMeta']['isCdata'],
          true);
      expect(
          result.keyMeta!['user']['children']['preferences']['xmlMeta']
              ['comment'],
          'Preferences section');
      expect(
          result.keyMeta!['user']['children']['preferences']['children']
              ['theme']['xmlMeta']['prefix'],
          'app');
    });
  });
}
