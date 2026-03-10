import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine_site/app/modules/examples/cubit/examples_cubit.dart';
import 'package:just_game_engine_site/app/modules/examples/cubit/examples_state.dart';

void main() {
  group('ExamplesCubit', () {
    late ExamplesCubit cubit;

    setUp(() {
      cubit = ExamplesCubit();
    });

    tearDown(() => cubit.close());

    test('initial state defaults to basic-setup', () {
      expect(cubit.state, const ExamplesState());
      expect(cubit.state.selectedExampleId, 'basic-setup');
    });

    blocTest<ExamplesCubit, ExamplesState>(
      'selectExample emits state with new example id',
      build: () => ExamplesCubit(),
      act: (cubit) => cubit.selectExample('ecs-demo'),
      expect: () => [const ExamplesState(selectedExampleId: 'ecs-demo')],
    );

    blocTest<ExamplesCubit, ExamplesState>(
      'selecting a different example then back to default emits both states',
      build: () => ExamplesCubit(),
      act: (cubit) {
        cubit.selectExample('ecs-demo');
        cubit.selectExample('basic-setup');
      },
      expect: () => [
        const ExamplesState(selectedExampleId: 'ecs-demo'),
        const ExamplesState(selectedExampleId: 'basic-setup'),
      ],
    );

    blocTest<ExamplesCubit, ExamplesState>(
      'selecting multiple examples emits each state change',
      build: () => ExamplesCubit(),
      act: (cubit) {
        cubit.selectExample('animation-demo');
        cubit.selectExample('particles-demo');
        cubit.selectExample('audio-demo');
      },
      expect: () => [
        const ExamplesState(selectedExampleId: 'animation-demo'),
        const ExamplesState(selectedExampleId: 'particles-demo'),
        const ExamplesState(selectedExampleId: 'audio-demo'),
      ],
    );
  });

  group('ExamplesState', () {
    test('supports value comparison', () {
      expect(const ExamplesState(), const ExamplesState());
    });

    test('different example ids are not equal', () {
      expect(
        const ExamplesState(selectedExampleId: 'ecs-demo'),
        isNot(const ExamplesState(selectedExampleId: 'audio-demo')),
      );
    });

    test('copyWith returns new instance with updated value', () {
      const state = ExamplesState();
      final updated = state.copyWith(selectedExampleId: 'input-demo');
      expect(updated.selectedExampleId, 'input-demo');
    });

    test('copyWith preserves value when null passed', () {
      const state = ExamplesState(selectedExampleId: 'particles-demo');
      final updated = state.copyWith();
      expect(updated.selectedExampleId, 'particles-demo');
    });

    test('props contains selectedExampleId', () {
      const state = ExamplesState(selectedExampleId: 'ecs-demo');
      expect(state.props, ['ecs-demo']);
    });
  });
}
