import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes_sql_storage/db_helper.dart';

class HomePage extends StatefulWidget{
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DbHelper? dbHelper;
  var titleController = TextEditingController();
  var descController = TextEditingController();
  List<Map<String, dynamic>> mNotes = [];

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper.getInstance();
    getNotes();
  }

  getNotes() async{
    mNotes = await dbHelper!.getAllNotes();
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: (mNotes.isNotEmpty ?
       ListView.builder(itemCount: mNotes.length, itemBuilder: (_, index){
        return ListTile(
            title: Text(mNotes[index][DbHelper.columnNoteTitle]),
            subtitle: Text(mNotes[index][DbHelper.columnNoteDesc]),
            trailing: Row(
              mainAxisSize: .min,
              children: [
                IconButton(onPressed: (){
                  titleController.text = mNotes[index][DbHelper.columnNoteTitle];
                  descController.text = mNotes[index][DbHelper.columnNoteDesc];
                  showModalBottomSheet(context: context, builder: (_){
                    return getBottomSheet(isUpdate: true, mId: mNotes[index][DbHelper.columnNoteId]);
                  });
                }, icon: Icon(Icons.edit_note)),
                IconButton(onPressed: () async {
                  bool isDeleted = await dbHelper!.deleteNote(id: mNotes[index][DbHelper.columnNoteId]);
                  if (isDeleted) {
                    getNotes();
                  }
                }, icon: Icon(Icons.delete))
              ],
            ),
        );
       }) :
      Center(child:
      Text("No Notes yet"))),
      floatingActionButton: FloatingActionButton(onPressed: (){
        titleController.clear();
        descController.clear();
          showModalBottomSheet(context: context, builder: (_){
            return getBottomSheet();
          });
      }, child: Icon(Icons.add))
    );
  }

  Widget getBottomSheet({bool isUpdate = false, int? mId}) {
    return Container(
        padding: .all(11),
        width: double.infinity,
        child:
        Column(children: [
          Text(isUpdate ? "Update Note" : "Add Note",style: TextStyle(fontWeight: .normal,fontSize: 22)),
          SizedBox(height: 10),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
                labelText: "Title",
                hintText: "Enter your title for note here..",
                border: OutlineInputBorder(
                    borderRadius: .circular(21)
                )
            ),
          ),
          SizedBox(height: 10),
          TextField(
            maxLines: 4,
            controller: descController,
            decoration: InputDecoration(
                alignLabelWithHint: true,
                labelText: "Description",
                hintText: "Enter your description for note here..",
                border: OutlineInputBorder(
                    borderRadius: .circular(21)
                )
            ),
          ),
          SizedBox(height: 10),
          Row(
            spacing: 15,
            mainAxisAlignment: .end,
            children: [
              OutlinedButton(onPressed: () async {
                bool isChanged = false;
                if (isUpdate) {
                  isChanged = await dbHelper!.updateNote(updateTitle: titleController.text, updateDesc: descController.text, id: mId!);
                } else {
                  isChanged = await dbHelper!.addNote(title: titleController.text, desc: descController.text);
                }
                if (isChanged) {
                  getNotes();
                }
              }, child: Text(isUpdate ? "Update" : "Save")),
              OutlinedButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text("Cancel"))
            ],)
        ],));
  }
}