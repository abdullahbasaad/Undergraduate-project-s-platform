import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduater/components/screenTitleWidget.dart';
import 'package:graduater/models/programming_languages.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:graduater/constant.dart';
import 'package:graduater/api/graduater_api.dart';

class AddLanguages extends StatefulWidget {
  @override
  _AddLanguagesState createState() => _AddLanguagesState();
}

class _AddLanguagesState extends State<AddLanguages> {
  final _formKey = GlobalKey<FormState>();

  String _progDoc;
  List<ProgrammingLanguages> _progs = [];
  int docLength;
  bool updateFlag = false;

  final _ctrlLangDesc = TextEditingController();

  @override
  void initState(){
    super.initState();
    setState(() {});
    _refreshProgList();
    updateFlag = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: ScreenTitleWidget(screenTitle: 'Add Programming Language'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _form(),
            _list(),
          ],
        ),
      ),
    );
  }

  _form() => Container(
    //color: Colors.white,
    padding: EdgeInsets.symmetric(vertical: 30,horizontal: 30),
    child: Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _ctrlLangDesc,
            style: kTextFormFieldStyleRegistration,
            decoration: InputDecoration(
              hintText: 'PROGRAMMING LANG. DESCRIPTION',
              focusColor: Colors.blue[900],
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
              prefixIcon: const Icon(
                Icons.list,
                color: Colors.blue,
              ),
            ),
            validator: (val) => (val.length==0? 'Field is required': null),
          ),
          SizedBox(height: 25.0),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Container(
              height: 40.0,
              margin: EdgeInsets.fromLTRB(30.0,0.0,30.0,10.0),
              child: Material(
                borderRadius: BorderRadius.circular(20.0),
                shadowColor: Colors.blueGrey,
                color: Colors.blue,
                child: GestureDetector(
                  onTap: () {
                    _onSubmit();
                  },
                  child: Center(
                    child: Text(
                      'SUBMIT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  _list() => Expanded(
    child: Card(
      margin: EdgeInsets.fromLTRB(20.0, 1.0, 20.0, 0),
      child: ListView.builder(
        padding: EdgeInsets.all(8),
        itemBuilder: (context,index) {
          return Column(
              children: [
                ListTile(
                  leading: Icon(Icons.list,
                      color: Colors.blue,
                      size: 40.0),
                  title: Text(_progs[index].langDesc,
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  trailing: IconButton(icon: Icon(Icons.delete_sweep,color: Colors.blue),
                    onPressed: () async{
                      Alert(
                        context: context,
                        type: AlertType.warning,
                        title: "Warning Message",
                        desc: "Are you sure?",
                        buttons: [
                          DialogButton(
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.black, fontSize: 20),
                            ),
                            onPressed: () => Navigator.pop(context),
                            color: Color.fromRGBO(0, 179, 134, 1.0),
                          ),
                          DialogButton(
                            child: Text(
                              "Yes",
                              style: TextStyle(color: Colors.blue[900], fontSize: 20),
                            ),
                            onPressed: () async{
                              await _deleteProgDocument(_progs[index].documentID);

                              _resetForm();
                              _refreshProgList();
                              Navigator.pop(context);
                            },
                            gradient: LinearGradient(colors: [
                              Color.fromRGBO(116, 116, 191, 1.0),
                              Color.fromRGBO(52, 138, 199, 1.0)
                            ]),
                          )
                        ],
                      ).show();
                    },),
                  onTap: (){
                    setState(() {
                      _progDoc = _progs[index].documentID;
                      _ctrlLangDesc.text = _progs[index].langDesc;
                      updateFlag = true;
                    });
                  },
                ),

                Divider(
                  height: 5.0,
                )
              ]
          );
        },
        itemCount: _progs.length,
      ),
    ),
  );

  Future<void> _deleteProgDocument (String documentID) {
    return Firestore.instance.collection('programmingLanguages').document(documentID).delete();
  }

  _resetForm(){
    _formKey.currentState.reset();
    _ctrlLangDesc.clear();
  }

  Future<List<ProgrammingLanguages>> _getProgList() async {
    QuerySnapshot qShot = await getProgDocuments();
    docLength = qShot.documents.length;

    return qShot.documents.map(
            (doc) => ProgrammingLanguages(
            doc.documentID,
            doc.data["langDesc"])
    ).toList();
  }

  _refreshProgList() async{
    List<ProgrammingLanguages> x = await _getProgList();
    setState(() {
      _progs = x;
    });
  }

  _onSubmit() async{
    var form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      if (!updateFlag)
        await addNewLang(docLength, _ctrlLangDesc.text);
      else
        await updateLang(_progDoc,_ctrlLangDesc.text);

      _refreshProgList();
      _resetForm();
      updateFlag = false;

      Alert(
        context: context,
        title: "Success!",
        desc: "Skill has been inserted",
        image: Image.asset("images/success.png"),
      ).show();
    }
  }
}
