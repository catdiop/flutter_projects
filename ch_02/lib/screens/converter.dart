import 'package:flutter/material.dart';

class Converter extends StatefulWidget {
  const Converter({Key? key}) : super(key: key);

  @override
  State<Converter> createState() => _ConverterState();
}

class _ConverterState extends State<Converter> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  double? _value;
  String? _uniteSouce;
  String? _uniteCible;
  String? _text;
  final TextEditingController _textEditController = TextEditingController();

  final Map<String, int> _measuredMaps = {
    'Métres': 0,
    'Kilométres': 1,
    'Grammes': 2,
    'Kilogrammes': 3,
    'Pieds': 4,
    'Miles': 5,
    'Pounds (lbs)': 6,
    'Ounces': 7
  };

  final List<List<double>> formules = [
    [1, 0.001, 0, 0, 3.28084, 0.000621371, 0, 0],
    [1000, 1, 0, 0, 3280.84, 0.621371, 0, 0],
    [0, 0, 1, 0.0001, 0, 0, 0.00220462, 0.035274],
    [0, 0, 1000, 1, 0, 0, 2.20462, 35.274],
    [0.3048, 0.0003048, 0, 0, 1, 0.000189394, 0, 0],
    [1609.34, 1.60934, 0, 0, 5280, 1, 0, 0],
    [0, 0, 453.592, 0.453592, 0, 0, 1, 16],
    [0, 0, 28.3495, 0.0283495, 3.28084, 0, 0.0625, 1],
  ];

  double? get value => _value;
  static const List<String> valuesDropdown = ['Metres', 'Pieds'];
  String dropdownValue1 = valuesDropdown.first;
  String dropdownValue2 = valuesDropdown.elementAt(1);

  double get target {
    if (dropdownValue1 == 'Metres') {
      return _value! / 2;
    } else {
      return _value! * 2;
    }
  }

  DropdownButton<String> buildDropdownButton(
      TYPE type, void Function(String?) onChange) {
    return DropdownButton(
        isExpanded: true,
        value: type == TYPE.SOURCE ? _uniteSouce : _uniteCible,
        onChanged: onChange,
        items: _measuredMaps.keys
            .map<DropdownMenuItem<String>>(
              (e) => DropdownMenuItem<String>(
                child: Text(e),
                value: e,
              ),
            )
            .toList());
  }

  String get text {
    if (dropdownValue1 == 'Metres') {
      return '$value métres vaut $target pieds';
    } else {
      return '$value pieds vaut $target métres';
    }
  }

  String? convertir(double? value, String? uniteSource, String? uniteCible) {
    if ((uniteSource != null && uniteSource.isNotEmpty) &&
        (uniteCible != null && uniteCible.isNotEmpty) &&
        value != null) {
      int source = _measuredMaps[uniteSource]!;
      int cible = _measuredMaps[uniteCible]!;
      double facteur = formules[source].elementAt(cible);
      double valeurApresConversion = facteur * value;
      return '$value $uniteSource vaut $valeurApresConversion $uniteCible';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _textEditController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  hintText: 'Entrez une valeur à convertir',
                  border: UnderlineInputBorder(),
                  labelText: 'Valeur'),
              onChanged: (value) => _value = double.tryParse(value),
            ),
            buildDropdownButton(
              TYPE.SOURCE,
              (value) {
                if (value != null) setState(() => _uniteSouce = value);
              },
            ),
            buildDropdownButton(
              TYPE.CIBLE,
              (value) {
                if (value != null) setState(() => _uniteCible = value);
              },
            ),
            ButtonBar(children: [
              TextButton(
                  onPressed: () {
                    _textEditController.clear();
                    setState(() => {_value = null});
                  },
                  child: const Text('Annuler')),
              ElevatedButton(
                onPressed: () {
                  var newText = convertir(_value, _uniteSouce, _uniteCible);
                  if (newText == null || newText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Conversion impossible'),
                      duration: const Duration(seconds: 1),
                      action: SnackBarAction(
                        label: 'ACTION',
                        onPressed: () {},
                      ),
                    ));
                  } else {
                    setState(() => _text = newText);
                  }
                },
                child: const Text('Convertir'),
              ),
            ]),
            if (_value != null) Text(text)
          ],
        ),
      ),
    );
  }
}

enum TYPE { SOURCE, CIBLE }
