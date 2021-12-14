import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

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
                  child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red, fontSize: 14.0)),
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
                  child: Text(AppLocalizations.of(context)!.loading,
                      style: const TextStyle(color: Colors.grey, fontSize: 16.0, backgroundColor: Colors.transparent)),
                )
              ]),
        );
      }
    },
  );
}

Widget buildFloatingAddButton(BuildContext context, String hintText, Widget Function(BuildContext) buildDialog) {
  return FloatingActionButton(
      tooltip: hintText,
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

Future<void> actionWithAlert(BuildContext context,
    {required Future<bool> Function() action,
    required String alertTitle,
    required String alertText,
    required String successText,
    String? okText,
    bool redButton = false}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(alertTitle),
      content: Text(alertText),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(AppLocalizations.of(context)!.alertCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(okText ?? AppLocalizations.of(context)!.alertOk,
              style: redButton ? const TextStyle(color: Colors.red) : null),
        ),
      ],
    ),
  );
  if (result != null && result) {
    if (await action()) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(successText)));
    }
  }
}

Future<void> removalWithAlert(BuildContext context, Future<bool> Function() removeAction) {
  return actionWithAlert(context,
      action: removeAction,
      alertTitle: AppLocalizations.of(context)!.removeAlertTitle,
      alertText: AppLocalizations.of(context)!.removeAlertText,
      successText: AppLocalizations.of(context)!.removeSuccess,
      okText: AppLocalizations.of(context)!.removeAlertOk,
      redButton: true);
}

Future<bool?> showAlert(BuildContext context, String text) => showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text(text),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.alertOk),
          ),
        ],
      ),
    );

ListTile emptyListTile(String text) => ListTile(
      title: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 48),
    );

Widget buildRichTextEditor(quill.QuillController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: quill.QuillToolbar.basic(
            controller: controller,
            showInlineCode: false,
            showImageButton: false,
            showVideoButton: false,
            showCameraButton: false,
            showListCheck: false,
            showBackgroundColorButton: false, // it can't be printed
            showLink: false, // it can't be printed
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(width: 2.0, color: Colors.grey), borderRadius: BorderRadius.circular(10.0)),
            child: quill.QuillEditor(
              controller: controller,
              readOnly: false, // true for view only mode
              autoFocus: true,
              scrollable: true,
              focusNode: FocusNode(),
              scrollController: ScrollController(),
              padding: const EdgeInsets.all(16.0),
              expands: true,
            ),
          ),
        )
      ],
    ),
  );
}
