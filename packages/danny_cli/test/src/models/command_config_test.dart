import 'package:danny_cli/src/models/command_config.dart';
import 'package:test/test.dart';

void main() {
  group('BranchCommandConfig', () {
    group('can be serialized', () {
      test('with sub commands', () {
        const config = BranchCommandConfig(
          name: 'baz',
          path: 'foo/bar',
          subCommands: [
            LeafCommandConfig(
              name: 'hello',
              path: 'foo/bar/baz',
              hasCustomCategory: true,
              hasCustomInvocation: false,
              hasCustomUsageFooter: true,
              hasCustomArgParser: false,
            ),
            LeafCommandConfig(
              name: 'world',
              path: 'foo/bar/baz',
              hasCustomCategory: false,
              hasCustomInvocation: true,
              hasCustomUsageFooter: false,
              hasCustomArgParser: true,
            ),
          ],
        );
        expect(
          config.toJson(),
          equals({
            'name': 'baz',
            'path': 'foo/bar',
            'isBranch': true,
            'subCommands': [
              {
                'name': 'hello',
                'path': 'foo/bar/baz',
                'isBranch': false,
                'hasCustomCategory': true,
                'hasCustomInvocation': false,
                'hasCustomUsageFooter': true,
                'hasCustomArgParser': false,
              },
              {
                'name': 'world',
                'path': 'foo/bar/baz',
                'isBranch': false,
                'hasCustomCategory': false,
                'hasCustomInvocation': true,
                'hasCustomUsageFooter': false,
                'hasCustomArgParser': true,
              },
            ],
          }),
        );
      });

      test('without sub commands', () {
        const config = BranchCommandConfig(
          name: 'baz',
          path: 'foo/bar',
          subCommands: [],
        );
        expect(
          config.toJson(),
          equals({
            'name': 'baz',
            'path': 'foo/bar',
            'isBranch': true,
            'subCommands': <Map<String, dynamic>>[],
          }),
        );
      });
    });

    group('toString', () {
      test('with sub commands', () {
        const config = BranchCommandConfig(
          name: 'baz',
          path: 'foo/bar',
          subCommands: [
            LeafCommandConfig(
              name: 'hello',
              path: 'foo/bar/baz',
              hasCustomCategory: true,
              hasCustomInvocation: false,
              hasCustomUsageFooter: true,
              hasCustomArgParser: false,
            ),
            LeafCommandConfig(
              name: 'world',
              path: 'foo/bar/baz',
              hasCustomCategory: false,
              hasCustomInvocation: true,
              hasCustomUsageFooter: false,
              hasCustomArgParser: true,
            ),
          ],
        );
        expect(
          config.toString(),
          config.toJson().toString(),
        );
      });

      test('without sub commands', () {
        const config = BranchCommandConfig(
          name: 'baz',
          path: 'foo/bar',
          subCommands: [],
        );
        expect(
          config.toString(),
          config.toJson().toString(),
        );
      });
    });

    test('hashCode', () {
      const config1 = BranchCommandConfig(
        name: 'a',
        path: 'b/c',
        subCommands: [
          LeafCommandConfig(
            name: 'foo',
            path: 'bar',
            hasCustomCategory: true,
            hasCustomInvocation: false,
            hasCustomUsageFooter: true,
            hasCustomArgParser: false,
          ),
        ],
      );
      const config2 = BranchCommandConfig(
        name: 'a',
        path: 'b/c',
        subCommands: [
          LeafCommandConfig(
            name: 'foo',
            path: 'bar',
            hasCustomCategory: true,
            hasCustomInvocation: false,
            hasCustomUsageFooter: true,
            hasCustomArgParser: false,
          ),
        ],
      );
      const config3 = BranchCommandConfig(
        name: 'a',
        path: 'b/c',
        subCommands: [
          LeafCommandConfig(
            name: 'a',
            path: '',
            hasCustomCategory: true,
            hasCustomInvocation: false,
            hasCustomUsageFooter: true,
            hasCustomArgParser: false,
          ),
          LeafCommandConfig(
            name: 'b',
            path: '',
            hasCustomCategory: true,
            hasCustomInvocation: false,
            hasCustomUsageFooter: true,
            hasCustomArgParser: true,
          ),
        ],
      );
      const config4 = BranchCommandConfig(
        name: 'foo',
        path: 'bar/baz',
        subCommands: [],
      );

      expect(config1.hashCode, config2.hashCode);
      expect(config1.hashCode, isNot(config3.hashCode));
      expect(config1.hashCode, isNot(config4.hashCode));
    });
  });

  group('LeafCommandConfig', () {
    test('can be serialized', () {
      const config = LeafCommandConfig(
        name: 'baz',
        path: 'foo/bar',
        hasCustomCategory: true,
        hasCustomInvocation: false,
        hasCustomUsageFooter: true,
        hasCustomArgParser: true,
      );
      expect(
        config.toJson(),
        equals(
          {
            'name': 'baz',
            'path': 'foo/bar',
            'isBranch': false,
            'hasCustomCategory': true,
            'hasCustomInvocation': false,
            'hasCustomUsageFooter': true,
            'hasCustomArgParser': true,
          },
        ),
      );
    });

    test('toString', () {
      const config = LeafCommandConfig(
        name: 'baz',
        path: 'foo/bar',
        hasCustomCategory: true,
        hasCustomInvocation: false,
        hasCustomUsageFooter: true,
        hasCustomArgParser: true,
      );
      expect(config.toString(), config.toJson().toString());
    });

    test('hashCode', () {
      const config1 = LeafCommandConfig(
        name: 'a',
        path: 'b',
        hasCustomCategory: true,
        hasCustomInvocation: false,
        hasCustomUsageFooter: true,
        hasCustomArgParser: false,
      );
      const config2 = LeafCommandConfig(
        name: 'a',
        path: 'b',
        hasCustomCategory: true,
        hasCustomInvocation: false,
        hasCustomUsageFooter: true,
        hasCustomArgParser: false,
      );
      const config3 = LeafCommandConfig(
        name: 'c',
        path: 'd',
        hasCustomCategory: false,
        hasCustomInvocation: false,
        hasCustomUsageFooter: false,
        hasCustomArgParser: true,
      );
      expect(config1.hashCode, config2.hashCode);
      expect(config1.hashCode, isNot(config3.hashCode));
    });
  });
}
