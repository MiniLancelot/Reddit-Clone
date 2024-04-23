import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/failure.dart';

//generic programming
typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;
