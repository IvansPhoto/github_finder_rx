import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart';
import 'package:get_it/get_it.dart';
import 'package:github_finder_rx/apiClasses.dart';

abstract class RouteNames {
  static const String index = '/';
  static const String menu = '/menu';
  static const String users = '/users';
  static const String profile = '/profile';
  static const String loading = '/loading';
  static const String error = '/error';
  static const String setPage = '/setpage';
  static const String selectedUsers = '/selectedUsers';
}

GetIt getIt = GetIt.instance;

class SearchParameters {
  String searchString;
  int pageNumber;
  int resultPerPage;

  SearchParameters({this.searchString, this.pageNumber = 1, this.resultPerPage = 5});

  void increasePage() => pageNumber++;

  void decreasePage() => pageNumber--;
}

class HttpConnection {}

class StreamService {
//	String _searchString;
//	int _page;
//	int _perPage;
//	StreamService(this._searchString, this._page, this._perPage);
//
//	void increasePage() => _page++;
//	void decreasePage() => _page--;
//
//	set setString(String newSearchString) => _searchString = newSearchString;
//	set setPage(int newPage) => _page = newPage;
//	set setPerPage(int newPerPage) => _perPage = newPerPage;
//
//	String get searchString => _searchString;
//	int get getPage => _page;
//	int get getPerPage => _perPage;
//
//	final _searchPageParams = BehaviorSubject<StreamService>();
//	Stream get streamSearchParams$ => _searchPageParams.stream;
//	StreamService get currentSearchParams => _searchPageParams.value;
//	set setSearchParams(StreamService currentSearchParams) => _searchPageParams.add(currentSearchParams);

  final _searchParameters = BehaviorSubject.seeded(SearchParameters(pageNumber: 1, resultPerPage: 5));
  Stream get streamSearch => _searchParameters.stream;
  SearchParameters get currentSearch => _searchParameters.value;
  set setSearch(currentSearch) => _searchParameters.add(currentSearch);

  final _gitHubUserResponse = BehaviorSubject<GitHubUserResponse>();
  Stream get streamGHUResponse$ => _gitHubUserResponse.stream;
  GitHubUserResponse get currentGHUResponse => _gitHubUserResponse.value;
  set setGHUResponse(GitHubUserResponse gitHubUserResponse) => _gitHubUserResponse.add(gitHubUserResponse);

  void searchUsers({@required BuildContext context, StreamService streamService}) async {
    setGHUResponse = null; //Set to null to make 'snapshot.hasData = false' in the page of search result.
    try {
      Response response = await get('https://api.github.com/search/users?q=${currentSearch.searchString}&per_page=${currentSearch.resultPerPage}&page=${currentSearch.pageNumber}');
      print('https://api.github.com/search/users?q=${currentSearch.searchString}&per_page=${currentSearch.resultPerPage}&page=${currentSearch.pageNumber}');
      setGHUResponse = GitHubUserResponse.fromJson(jsonDecode(response.body), response.headers['status']);
    } catch (error) {
      Navigator.pushNamed(context, RouteNames.error, arguments: error); //Check error type.
      print('The error: ' + error);
    }
  }

  static void showUserProfileHero({BuildContext context, String url}) async {
    try {
      Response response = await get(url);
      UserProfile userProfile = UserProfile.fromJson(jsonDecode(response.body));
      Navigator.pushNamed(context, RouteNames.profile, arguments: userProfile);
    } catch (error) {
      print(error);
      Navigator.pushNamed(context, RouteNames.error, arguments: error); ////Check error type.
    }
  }
}
