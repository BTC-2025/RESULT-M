enum HomeFeedTab { forYou, complaints, polls, trending, following }

extension HomeFeedTabLabel on HomeFeedTab {
  String get label {
    switch (this) {
      case HomeFeedTab.forYou:
        return 'For You';
      case HomeFeedTab.complaints:
        return 'Complaints';
      case HomeFeedTab.polls:
        return 'Polls';
      case HomeFeedTab.trending:
        return 'Trending';
      case HomeFeedTab.following:
        return 'Following';
    }
  }
}
