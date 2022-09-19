import 'package:flutter/material.dart';

class StreamWidget<T> extends StatelessWidget {
  final Widget Function(T snapshot) child;
  final Stream<T>? stream;

  const StreamWidget({Key? key, required this.child, required this.stream})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Stream builder of T
    return StreamBuilder<T>(
      /// Stream builder of T
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.connectionState == ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(
              value: 1,
              color: Colors.red,
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.none) {
          return errorConnection();
        } else if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            var data = snapshot.data;
            if (data == null) {
              return errorConnection();
            } else {
              return child(data);
            }
          } else {
            return errorConnection();
          }
        } else {
          return const CircularProgressIndicator.adaptive();
        }
      },
    );
  }

  Center errorConnection() =>
      const Center(child: Icon(Icons.wifi_off, color: Colors.red));
}
