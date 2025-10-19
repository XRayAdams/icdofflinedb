import 'package:flutter/material.dart';
import 'package:icdofflinedb/ui/widgets/error_display.dart';
import 'package:icdofflinedb/ui/widgets/filter_control.dart';
import 'package:icdofflinedb/ui/widgets/view_result.dart';
import 'package:provider/provider.dart';
import 'package:yaru/yaru.dart';

import '../providers/db_settings_provider.dart';
import '../providers/result_provider.dart';
import 'widgets/about_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _editingController = TextEditingController();

  bool areProvidersLoaded = false;
  bool filterVisible = false;

  @override
  Widget build(BuildContext context) {
    DbSettingsProvider settings = Provider.of<DbSettingsProvider>(context);
    ResultProvider resultProvider = Provider.of<ResultProvider>(context);

    return Scaffold(
      appBar: YaruWindowTitleBar(title: Text(widget.title), actions: const [AboutButton()]),
      body: Padding(
        padding: const EdgeInsets.all(kYaruPagePadding),
        child: !settings.isLoaded
            ? const Center(child: Center(child: CircularProgressIndicator()))
            : settings.isErrorLoadingDB
            ? const ErrorDisplay()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _editingController,
                          decoration: InputDecoration(
                            labelText: 'Enter a search term',
                            alignLabelWithHint: true,
                            suffixIcon: YaruIconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () async {
                                await _clearSearch(settings);
                              },
                            ),
                          ),
                          onChanged: (value) {
                            settings.searchText = value;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            filterVisible = !filterVisible;
                          });
                        },
                        icon: const Icon(Icons.filter_list_sharp),
                        label: Text(filterVisible ? "Hide Filter" : "Show Filter"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (!filterVisible) Container() else const FilterControl(),
                  Expanded(
                    child: Material(
                      clipBehavior: Clip.antiAlias,
                      color: Colors.transparent,
                      child: ListView.builder(
                        itemCount: settings.resultList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: SizedBox(
                              width: 80,
                              child: Text(
                                settings.resultList[index].code,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(settings.resultList[index].rType),
                                const SizedBox(height: 5),
                                Text(settings.resultList[index].description),
                                const Divider(height: 2),
                              ],
                            ),
                            onTap: () {
                              resultProvider.setResult(settings.resultList[index], settings);
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return ViewResult();
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topRight,
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: <TextSpan>[
                          const TextSpan(text: 'Record(s) found : '),
                          TextSpan(
                            text: '${settings.resultList.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _clearSearch(DbSettingsProvider settings) async {
    return Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _editingController.clear();
        settings.searchText = '';
        settings.resultList.clear();
      });
    });
  }
}
