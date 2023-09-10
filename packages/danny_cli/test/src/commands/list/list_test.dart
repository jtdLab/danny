import 'package:danny_cli/src/command_runner.dart';
import 'package:danny_cli/src/commands/commands.dart';
import 'package:danny_cli/src/logging.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../mock_env.dart';
import '../../../mocks.dart';
import '../../../utils.dart';

const expectedUsage = [
  'List the commands of a project.',
  '',
  'Usage: danny list',
  '-h, --help    Print this usage information.',
  '',
  'Run "danny help" to see global options.',
];

void main() {
  group('danny list', () {
    late Logger logger;
    late ListCommand command;

    setUp(() {
      logger = MockLogger();
      command = ListCommand(logger: logger);
    });

    test(
      'help',
      overridePrint((printLogs) async {
        final commandRunner = DannyCommandRunner();

        await commandRunner.run(['list', '--help']);
        expect(printLogs, equals(expectedUsage));

        printLogs.clear();

        await commandRunner.run(['list', '-h']);
        expect(printLogs, equals(expectedUsage));
      }),
    );

    test(
      'lists the commands of a project successfully.',
      withMockFs(() async {
        await createProject();

        await command.run();

        verifyInOrder([
          () => logger.info('greet hello'),
          () => logger.info('greet friendly hello'),
        ]);
      }),
    );
  });
}
