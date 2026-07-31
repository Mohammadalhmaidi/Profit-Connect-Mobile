import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConditionedBlocBuilder<B extends BlocBase<S>, S>
    extends BlocBuilder<B, S> {
  ConditionedBlocBuilder({
    super.key,
    required super.builder,
    super.bloc,
    super.buildWhen,
  });
}

class ConditionedBlocListener<B extends BlocBase<S>, S>
    extends BlocListener<B, S> {
  ConditionedBlocListener({
    super.key,
    required super.listener,
    super.bloc,
    super.listenWhen,
    super.child,
  });
}

extension BlocSelectorExtension<B extends BlocBase<S>, S> on BlocBuilder<B, S> {
  static BlocBuilder<B, S> withCondition<B extends BlocBase<S>, S>({
    required B bloc,
    required S Function(S) selector,
    required Widget Function(BuildContext, S) builder,
  }) {
    return BlocBuilder<B, S>(
      bloc: bloc,
      buildWhen: (previous, current) => selector(previous) != selector(current),
      builder: builder,
    );
  }
}
