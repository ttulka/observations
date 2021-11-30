import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget buildFutureWidget<T>({required Future<T> future, required Widget Function(T) buildWidget}) {
  return FutureBuilder<T>(
    future: future,
    builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
      if (snapshot.hasData) {
        return buildWidget(snapshot.data!);
      } else if (snapshot.hasError) {
        return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 22),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                )
              ]),
        );
      } else {
        return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(child: CircularProgressIndicator(), width: 60, height: 60),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(AppLocalizations.of(context)!.loading),
                )
              ]),
        );
      }
    },
  );
}

Widget buildFloatingAddButton(BuildContext context, Widget Function(BuildContext) buildDialog) {
  return FloatingActionButton(
      tooltip: AppLocalizations.of(context)!.addClassroomTitle,
      child: const Icon(Icons.add),
      onPressed: () async {
        final result = await Navigator.push(context, MaterialPageRoute(builder: buildDialog));
        if (result != null && result) {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.addSuccess)));
        }
      });
}
