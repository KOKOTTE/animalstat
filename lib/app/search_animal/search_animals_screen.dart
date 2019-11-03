import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livestock/app/animal/animal_details_screen.dart';
import 'package:livestock/app/animal/bloc/bloc.dart';
import 'package:livestock/app/search_animal/bloc/bloc.dart';
import 'package:livestock/app/search_animal/bloc/search_animal_state.dart';
import 'package:livestock/src/ui/theming.dart';
import 'package:livestock/src/ui/widgets/livestock_health_status_label.dart';
import 'package:livestock/src/ui/widgets/livestock_number_box.dart';
import 'package:livestock/src/ui/widgets/livestock_search_text_field.dart';
import 'package:animal_repository/animal_repository.dart';

class SearchAnimalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
              BlocProvider.of<SearchAnimalBloc>(context)
                  .add(QueryChanged(query: ''));
            },
          ),
        ],
        brightness: Brightness.dark,
        leading: Container(),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(79.0),
          child: Center(
            child: Container(
              color: kAccentColor,
              child: Padding(
                padding: const EdgeInsets.all(9.0),
                child: LivestockSearchTextField(
                  onChanged: (value) =>
                      BlocProvider.of<SearchAnimalBloc>(context)
                          .add(QueryChanged(query: value)),
                ),
              ),
            ),
          ),
        ),
        elevation: 0.0,
        titleSpacing: 0.0,
        title: Text('Livestock'),
      ),
      body: BlocBuilder<SearchAnimalBloc, SearchAnimalState>(
        builder: (BuildContext context, SearchAnimalState state) {
          if (state is ResultsUpdatedState) {
            return ListView.builder(
              itemBuilder: (context, index) =>
                  _buildResultRow(context, state.searchResults[index]),
              itemCount: state.searchResults.length,
            );
          }

          return Container();
        },
      ),
    );
  }

  Widget _buildResultRow(
      BuildContext context, AnimalSearchResult searchResult) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => BlocProvider<AnimalBloc>(
            builder: (_) => AnimalBloc()
              ..add(AnimalSelected(animalId: searchResult.animalNumber)),
            child: AnimalDetailsScreen(),
          ),
        ));
      },
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              top: 10.0,
              right: 15.0,
              bottom: 10.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                LivestockNumberBox(
                  animalNumber: searchResult.animalNumber.toString(),
                ),
                Expanded(
                  child: Container(),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: LivestockHealthStatusLabel(
                    healthStatus: searchResult.currentHealthStatus,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                )
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}