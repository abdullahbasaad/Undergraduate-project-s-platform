import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduater/components/screenTitleWidget.dart';
import 'package:graduater/models/skills.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:graduater/api/graduater_api.dart';
import '../constant.dart';

class AddSkills extends StatefulWidget {
  @override
  _AddSkillsState createState() => _AddSkillsState();
}

class _AddSkillsState extends State<AddSkills> {
  final _formKey = GlobalKey<FormState>();

  String _skillDoc;
  List<Skills> _skills = [];
  int docLength;
  bool updateFlag = false;

  final _ctrlSkillDesc = TextEditingController();

  @override
  void initState(){
    super.initState();
    setState(() {});
    _refreshSkillList();
    updateFlag = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
      title: ScreenTitleWidget(screenTitle: 'Add Skills'),
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
            controller: _ctrlSkillDesc,
            style: kTextFormFieldStyleRegistration,
            decoration: InputDecoration(
              hintText: 'SKILL DESCRIPTION',
              focusColor: Colors.blue[900],
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
              prefixIcon: const Icon(
                Icons.list,
                color: Colors.blue,
              ),
            ),
            //onChanged: (val) => setState(() => _skill.skillDesc = val),
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
                  title: Text(_skills[index].skillDesc,
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
                                await _deleteSkillDocument(_skills[index].documentID);

                              _resetForm();
                              _refreshSkillList();
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
                      _skillDoc = _skills[index].documentID;
                      _ctrlSkillDesc.text = _skills[index].skillDesc;
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
        itemCount: _skills.length,
      ),
    ),
  );

  Future<void> _deleteSkillDocument (String documentID) {
    return Firestore.instance.collection('skill').document(documentID).delete();
  }

  _resetForm(){
    _formKey.currentState.reset();
    _ctrlSkillDesc.clear();
  }

  Future<List<Skills>> _getSkillList() async {
    QuerySnapshot qShot = await getSkillDocuments();
    docLength = qShot.documents.length;

    return qShot.documents.map(
            (doc) => Skills(
              doc.documentID,
              doc.data["skillDesc"])
    ).toList();
  }

  _refreshSkillList() async{
    List<Skills> x = await _getSkillList();
    setState(() {
      _skills = x;
    });
  }

  _onSubmit() async{
    var form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      if (!updateFlag)
        await addNewSkill(docLength, _ctrlSkillDesc.text);
      else
        await updateSkill(_skillDoc,_ctrlSkillDesc.text);

      _refreshSkillList();
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
