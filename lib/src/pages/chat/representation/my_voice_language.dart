import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MyVoiceLanguge extends StatefulWidget {
  const MyVoiceLanguge({Key? key}) : super(key: key);

  @override
  _MyVoiceLangugeState createState() => _MyVoiceLangugeState();
}

final snackBar = SnackBar(
  content: Text('changeVoiceSuccess'.tr),
  backgroundColor: Colors.green,
  duration: const Duration(seconds: 2),
);

class _MyVoiceLangugeState extends State<MyVoiceLanguge> {
  late Future<List<LocaleName>> _localesFuture;
  List<LocaleName> _locales = [];

  @override
  void initState() {
    super.initState();
    _localesFuture = getLocales();
  }

  @override
  Widget build(BuildContext context) {
    SharedPreferences prefs = Get.find<SharedPreferences>();
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        title: Row(
          children: [
            Text(
              'language'.tr,
              // align left
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: LocaleSearchDelegate(_locales),
              );
              if (result != null) {
                prefs.setString('localeId', result.localeId);
                prefs.setString('voiceRecord', result.name);
                debugPrint('localeId: ${result.localeId}');
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<LocaleName>>(
        future: _localesFuture,
        builder:
            (BuildContext context, AsyncSnapshot<List<LocaleName>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            _locales = snapshot.data ?? [];
            return ListView.builder(
              itemCount: _locales.length,
              itemBuilder: (BuildContext context, int index) {
                final locale = _locales[index];
                return ListTile(
                  title: Text(locale.name),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    prefs.setString('localeId', locale.localeId);
                    prefs.setString('voiceRecord', locale.name);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<LocaleName>> getLocales() async {
    final speech = Get.find<stt.SpeechToText>();
    await speech.initialize();
    return speech.locales();
  }
}

class LocaleSearchDelegate extends SearchDelegate<LocaleName> {
  final List<LocaleName> locales;

  LocaleSearchDelegate(this.locales);

  @override
  String get searchFieldLabel => 'Search languages';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    SharedPreferences prefs = Get.find<SharedPreferences>();
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        // Default locale
        String id = prefs.getString('localeId') ?? 'en_US';
        String name = prefs.getString('voiceRecord') ?? 'English';
        close(context, LocaleName(id, name));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = locales
        .where(
            (locale) => locale.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) {
        final locale = results[index];
        return ListTile(
          title: Text(locale.name),
          subtitle: Text(locale.localeId),
          onTap: () {
            final snackBar = SnackBar(
              content: Text('changeVoiceSuccess'.tr),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            // not see result
            close(context, locale);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = locales
        .where(
            (locale) => locale.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) {
        final locale = results[index];
        return ListTile(
          title: Text(locale.name),
          subtitle: Text(locale.localeId),
          onTap: () {
            close(context, locale);
          },
        );
      },
    );
  }
}
