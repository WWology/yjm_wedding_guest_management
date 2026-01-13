import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget {
  const SearchAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .only(top: 24.0),
      child: AppBar(
        centerTitle: true,
        title: LayoutBuilder(
          builder: (context, constraints) {
            return SearchAnchor(
              builder: (context, controller) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth < 624
                        ? 312
                        : constraints.maxWidth / 2,
                  ),
                  child: Material(
                    elevation: 6.0,
                    shadowColor: ColorScheme.of(context).shadow,
                    color: ColorScheme.of(context).surfaceContainerHigh,
                    shape: const StadiumBorder(),
                    child: Padding(
                      padding: const .symmetric(horizontal: 16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hint: const Text('Search guest', textAlign: .center),
                          icon: Icon(Icons.search),
                          enabledBorder: .none,
                          border: .none,
                          focusedBorder: .none,
                          contentPadding: .zero,
                        ),
                      ),
                    ),
                  ),
                );
              },
              suggestionsBuilder: (context, controller) {
                return List<ListTile>.generate(5, (int index) {
                  final String item = 'item $index';
                  return ListTile(title: Text(item), onTap: () {});
                });
              },
            );
          },
        ),
      ),
    );
  }
}
