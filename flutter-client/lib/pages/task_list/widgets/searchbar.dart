import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({Key? key, required this.onChangeSearchText})
      : super(key: key);

  final ValueChanged<String> onChangeSearchText;

  @override
  State<StatefulWidget> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: TextField(
        decoration: const InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 2),
            child: Icon(
              CupertinoIcons.search,
              size: 18,
              color: Color(0xFF8E8E93),
            ),
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 18 + 12,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          filled: true,
          fillColor: Color(0x1F767680),
          hintText: '検索',
        ),
        textAlignVertical: TextAlignVertical.bottom,
        style: const TextStyle(fontSize: 15),
        onChanged: widget.onChangeSearchText,
      ),
    );
  }
}
