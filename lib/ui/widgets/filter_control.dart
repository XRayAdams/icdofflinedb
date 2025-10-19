import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaru/yaru.dart';

import '../../models/code_selector.dart';
import '../../providers/db_settings_provider.dart';

class FilterControl extends StatefulWidget {
  const FilterControl({super.key});

  @override
  State<FilterControl> createState() => _FilterControlState();
}

class _FilterControlState extends State<FilterControl> {
  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<DbSettingsProvider>(context, listen: false);
    return YaruSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text("Search in:"),
                YaruCheckboxListTile(
                  title: Text("ICD9 Diagnosis"),
                  value: settings.icd9Diag,
                  onChanged: (bool? value) {
                    setState(() {
                      settings.icd9Diag = value!;
                    });
                  },
                ),
                YaruCheckboxListTile(
                  title: Text("ICD9 Procedures"),
                  value: settings.icd9Proc,
                  onChanged: (bool? value) {
                    setState(() {
                      settings.icd9Proc = value!;
                    });
                  },
                ),
                YaruCheckboxListTile(
                  title: Text("ICD10 Diagnosis"),
                  value: settings.icd10Diag,
                  onChanged: (bool? value) {
                    setState(() {
                      settings.icd10Diag = value!;
                    });
                  },
                ),
                YaruCheckboxListTile(
                  title: Text("ICD10 Procedures"),
                  value: settings.icd10Proc,
                  onChanged: (bool? value) {
                    setState(() {
                      settings.icd10Proc = value!;
                    });
                  },
                ),
                SizedBox(height: 10),
                Text('Section (ICD10 only)'),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: YaruPopupMenuButton<CodeSection>(
                        icon: Icon(Icons.filter_list_sharp),
                        tooltip: 'Sections',
                        initialValue: settings.selectedSection,
                        childPadding: EdgeInsets.all(5),
                        child: Text(
                          settings.selectedSection.description,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: settings.selectedSection.id == 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        itemBuilder: (BuildContext context) {
                          return settings.sections.map<PopupMenuEntry<CodeSection>>((CodeSection value) {
                            return PopupMenuItem<CodeSection>(
                              value: value,
                              child: Text(
                                value.description,
                                style: TextStyle(fontWeight: value.id == 0 ? FontWeight.bold : FontWeight.normal),
                              ),
                            );
                          }).toList();
                        },
                        onSelected: (value) {
                          setState(() {
                            settings.selectedSection = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
