# frozen_string_literal: true

require 'spec_helper'

describe NewsSearch do
  let(:affiliate) { affiliates(:basic_affiliate) }

  before do
    ElasticNewsItem.recreate_index
    NewsItem.all.each(&:save!)
    ElasticNewsItem.commit
  end

  describe '#initialize(options)' do
    let(:feed) { affiliate.rss_feeds.first }

    let(:filterable_search_options) do
      { affiliate: affiliate,
        channel: feed.id }
    end

    it_behaves_like 'an initialized filterable search'

    context 'when options does not include sort_by' do
      subject(:search) { described_class.new filterable_search_options }

      its(:sort_by_relevance?) { is_expected.to be false }
      its(:sort) { is_expected.to eq('published_at:desc') }
    end

    context 'when show_only_media_content is false' do
      subject(:search) { described_class.new(filterable_search_options) }

      its(:tags) { is_expected.to eq([]) }
    end

    context 'when show_only_media_content is true' do
      subject(:search) { described_class.new(filterable_search_options) }

      let(:feed) { affiliate.rss_feeds.find_by(name: 'USGS Media RSS') }

      its(:tags) { is_expected.to eq(['image']) }
    end

    context 'when a valid RSS feed is specified' do
      it 'sets the rss_feed member' do
        expect(described_class.new(query: 'element', channel: feed.id, affiliate: affiliate).rss_feed).to eq(feed)
      end
    end

    context "when another affiliate's RSS feed is specified" do
      it 'sets the rss_feed member to nil' do
        another_feed = rss_feeds(:another)
        expect(described_class.new(query: 'element', channel: another_feed.id, affiliate: affiliate).rss_feed).to be_nil
      end
    end

    context 'when channel is not a valid number' do
      it 'sets the rss_feed member to nil' do
        expect(described_class.new(query: 'element', channel: { 'foo' => 'bar' }, affiliate: affiliate).rss_feed).to be_nil
      end
    end

    context "when the query param isn't set" do
      it "sets 'query' to a blank string" do
        expect(described_class.new(channel: feed.id, affiliate: affiliate).query).to be_blank
      end
    end

    it 'does not overwrite per_page option' do
      news_search = described_class.new(channel: feed.id, affiliate: affiliate, per_page: '15')
      expect(news_search.per_page).to eq(15)
    end
  end

  describe '#run' do
    context 'when searching with really long queries' do
      before do
        @search = described_class.new(query: 'X' * (Search::MAX_QUERYTERM_LENGTH + 1), affiliate: affiliate)
      end

      it 'returns false when searching' do
        expect(@search.run).to be false
      end

      it 'has 0 results' do
        @search.run
        expect(@search.results.size).to eq(0)
        expect(@search.total).to eq(0)
        expect(@search.module_tag).to be_nil
      end

      it 'sets the error message' do
        @search.run
        expect(@search.error_message).not_to be_nil
      end
    end

    context 'when searching with a blank query' do
      before do
        @search = described_class.new(query: '   ', affiliate: affiliate)
      end

      it 'returns true when searching' do
        expect(@search.run).to be true
      end

      it 'returns more than 0 results' do
        @search.run
        expect(@search.results.size).to be > 0
      end

      it 'does not set error message' do
        @search.run
        expect(@search.error_message).to be_nil
      end
    end

    context 'when a valid active RSS feed is specified' do
      it 'only searches for news items from that feed' do
        feed = affiliate.rss_feeds.first
        search = described_class.new(query: 'element', channel: feed.id, affiliate: affiliate,
                                     contributor: 'contributor', publisher: 'publisher', subject: 'subject')
        expect(ElasticNewsItem).to receive(:search_for).
          with(q: 'element', rss_feeds: [feed], excluded_urls: affiliate.excluded_urls,
               since: nil, until: nil,
               offset: 0, size: 10,
               contributor: 'contributor', subject: 'subject', publisher: 'publisher',
               sort: 'published_at:desc',
               tags: [], language: 'en')
        expect(search.run).to be true
      end
    end

    context 'when a valid managed RSS feed is specified' do
      let(:feed) { rss_feeds(:managed_video) }
      let(:youtube_profile_feed) { rss_feeds(:nps_youtube_feed) }

      context 'when per_page option is not set' do
        it 'sets per_page to 20' do
          search = described_class.new(query: 'element', channel: feed.id, affiliate: affiliate)
          expect(ElasticNewsItem).to receive(:search_for).
            with(q: 'element', rss_feeds: [youtube_profile_feed], excluded_urls: affiliate.excluded_urls,
                 since: nil, until: nil,
                 offset: 0, size: 20,
                 contributor: nil, subject: nil, publisher: nil,
                 sort: 'published_at:desc',
                 tags: [], language: 'en')
          expect(search.run).to be true
        end
      end

      context 'when per_page option is set' do
        it 'does not change the initial per_page value' do
          search = described_class.new(query: 'element', channel: feed.id, affiliate: affiliate, per_page: '15')
          expect(ElasticNewsItem).to receive(:search_for).
            with(q: 'element', rss_feeds: [youtube_profile_feed], excluded_urls: affiliate.excluded_urls,
                 since: nil, until: nil,
                 offset: 0, size: 15,
                 contributor: nil, subject: nil, publisher: nil,
                 sort: 'published_at:desc',
                 tags: [], language: 'en')
          expect(search.run).to be true
        end
      end
    end

    context 'when a valid media RSS feed is specified' do
      let(:feed) { rss_feeds(:media_feed) }

      context 'when per_page option is not set' do
        it 'sets per_page to 20' do
          search = described_class.new(query: 'element', channel: feed.id, affiliate: affiliate)
          expect(ElasticNewsItem).to receive(:search_for).
            with(q: 'element', rss_feeds: [feed], excluded_urls: affiliate.excluded_urls,
                 since: nil, until: nil,
                 offset: 0, size: 20,
                 contributor: nil, subject: nil, publisher: nil,
                 sort: 'published_at:desc',
                 tags: %w[image], language: 'en')
          expect(search.run).to be true
        end
      end

      context 'when per_page option is set' do
        it 'does not change the initial per_page value' do
          search = described_class.new(query: 'element', channel: feed.id, affiliate: affiliate, per_page: '15')
          expect(ElasticNewsItem).to receive(:search_for).
            with(q: 'element', rss_feeds: [feed], excluded_urls: affiliate.excluded_urls,
                 since: nil, until: nil,
                 offset: 0, size: 15,
                 contributor: nil, subject: nil, publisher: nil,
                 sort: 'published_at:desc',
                 tags: %w[image], language: 'en')
          expect(search.run).to be true
        end
      end
    end

    context 'when no RSS feed is specified' do
      it 'searches for news items from all active feeds for the affiliate' do
        one_week_ago = Time.current.advance(weeks: -1).beginning_of_day
        search = described_class.new(query: 'element', tbs: 'w', affiliate: affiliate)
        expect(ElasticNewsItem).to receive(:search_for).
          with(q: 'element', rss_feeds: affiliate.rss_feeds.navigable_only, excluded_urls: affiliate.excluded_urls,
               since: one_week_ago, until: nil,
               offset: 0, size: 10,
               contributor: nil, subject: nil, publisher: nil,
               sort: 'published_at:desc',
               tags: [], language: 'en')
        search.run
      end
    end

    context 'when searching with since_date' do
      it 'searches for NewsItem with since option' do
        feed = mock_model(RssFeed, is_managed?: false, show_only_media_content?: false)
        allow(affiliate).to receive_message_chain(:rss_feeds, :find_by).and_return(feed)

        news_search = described_class.new(query: 'element', channel: feed.id, affiliate: affiliate, since_date: '10/1/2012')
        expect(ElasticNewsItem).to receive(:search_for).
          with(q: 'element', rss_feeds: [feed], excluded_urls: affiliate.excluded_urls,
               since: Time.parse('2012-10-01 00:00:00Z'), until: nil,
               offset: 0, size: 10,
               contributor: nil, subject: nil, publisher: nil,
               sort: 'published_at:desc',
               tags: [], language: 'en')

        news_search.run
      end
    end

    context 'when searching with until_date' do
      it 'searches for NewsItem with until option' do
        feed = mock_model(RssFeed, is_managed?: false, show_only_media_content?: false)
        allow(affiliate).to receive_message_chain(:rss_feeds, :find_by).and_return(feed)

        until_ts = DateTime.parse('2012-10-31')
        expect(DateTime).to receive(:strptime).with('10/31/2012', '%m/%d/%Y').and_return(until_ts.clone)
        news_search = described_class.new(query: 'element', channel: feed.id, affiliate: affiliate, until_date: '10/31/2012')
        expect(ElasticNewsItem).to receive(:search_for).
          with(q: 'element', rss_feeds: [feed], excluded_urls: affiliate.excluded_urls,
               since: nil, until: until_ts.utc.end_of_day,
               offset: 0, size: 10,
               contributor: nil, subject: nil, publisher: nil,
               sort: 'published_at:desc',
               tags: [], language: 'en')

        news_search.run
      end
    end

    context 'when sorting by relevance' do
      it 'passes in the sort_by param' do
        feed = affiliate.rss_feeds.first
        search = described_class.new(query: 'element', channel: feed.id, affiliate: affiliate,
                                     contributor: 'contributor', publisher: 'publisher', subject: 'subject',
                                     sort_by: 'r')
        expect(ElasticNewsItem).to receive(:search_for).
          with(q: 'element', rss_feeds: [feed], excluded_urls: affiliate.excluded_urls,
               since: nil, until: nil,
               offset: 0, size: 10,
               contributor: 'contributor', subject: 'subject', publisher: 'publisher',
               sort: nil,
               tags: [], language: 'en')
        expect(search.run).to be true
      end
    end

    context 'when response is present' do
      it 'assigns the correct start and end record' do
        feed = affiliate.rss_feeds.first
        search = described_class.new(query: 'element', channel: feed.id, affiliate: affiliate, page: 2, per_page: '15')
        results = [mock_model(NewsItem, title: 'result1', description?: true, url: 'http://search.gov/1'),
                   mock_model(NewsItem, title: 'result2', description?: true, url: 'http://search.gov/2')]
        response = double(ElasticNewsItemResults, total: 17, offset: 15, aggregations: [], results: results)
        expect(ElasticNewsItem).to receive(:search_for).
          with(q: 'element', rss_feeds: [feed], excluded_urls: affiliate.excluded_urls,
               since: nil, until: nil,
               offset: 15, size: 15,
               contributor: nil, subject: nil, publisher: nil,
               sort: 'published_at:desc',
               tags: [], language: 'en').
          and_return(response)

        search.run
        expect(search.startrecord).to eq(16)
        expect(search.endrecord).to eq(17)
      end

      context 'when the NewsItem description is blank and body is present' do
        it 'overrides description with body' do
          feed = affiliate.rss_feeds.first
          search = described_class.new(query: 'element', channel: feed.id, affiliate: affiliate)

          result_1 = mock_model(NewsItem, title: 'element result1', description?: false, body: 'result 1 body', url: 'http://search.gov/1')
          result_2 = mock_model(NewsItem, title: 'element result2', description?: true, body: 'result 2 body', url: 'http://search.gov/2')
          results = [result_1, result_2]

          response = double(ElasticNewsItemResults, total: 2, offset: 0, aggregations: [], results: results)
          expect(ElasticNewsItem).to receive(:search_for).
            with(q: 'element', rss_feeds: [feed], excluded_urls: affiliate.excluded_urls,
                 since: nil, until: nil,
                 offset: 0, size: 10,
                 contributor: nil, subject: nil, publisher: nil,
                 sort: 'published_at:desc',
                 tags: [], language: 'en').
            and_return(response)

          expect(result_1).to receive(:description=).with('result 1 body')

          search.run
        end
      end

      context 'when the NewsItem description is not highlighted and body is highlighted' do
        it 'overrides description with body' do
          feed = affiliate.rss_feeds.first
          search = described_class.new(query: 'highlighted', channel: feed.id, affiliate: affiliate)

          result_1 = mock_model(NewsItem,
                                title: 'result1',
                                description?: true,
                                description: "\uE000highlighted\uE001 result 1 description",
                                body: 'result 1 body',
                                url: 'http://search.gov/1')
          result_2 = mock_model(NewsItem,
                                title: 'result2',
                                description?: true,
                                description: 'result 2 description',
                                body: "\uE000highlighted\uE001 result 2 body",
                                url: 'http://search.gov/2')
          results = [result_1, result_2]

          response = double(ElasticNewsItemResults, total: 2, offset: 0, aggregations: [], results: results)
          expect(ElasticNewsItem).to receive(:search_for).
            with(q: 'highlighted', rss_feeds: [feed], excluded_urls: affiliate.excluded_urls,
                 since: nil, until: nil,
                 offset: 0, size: 10,
                 contributor: nil, subject: nil, publisher: nil,
                 sort: 'published_at:desc',
                 tags: [], language: 'en').
            and_return(response)

          expect(result_2).to receive(:description=).with("\uE000highlighted\uE001 result 2 body")

          search.run
        end
      end
    end
  end

  describe '#cache_key' do
    let(:options) { { query: 'element', affiliate: affiliate } }
    let(:feed) { rss_feeds(:managed_video) }
    let(:since_a_week_ago) { Date.current.advance(weeks: -1).to_s }

    it 'outputs a key based on the affiliate id, query, channel, tbs, since-until, page, and per_page parameters' do
      expect(described_class.new(options.merge(tbs: 'w', channel: feed.id, page: 2, per_page: 21)).cache_key).to eq("#{affiliate.id}:element:#{feed.id}:#{since_a_week_ago}:2:21")
      expect(described_class.new(options.merge(channel: feed.id)).cache_key).to eq("#{affiliate.id}:element:#{feed.id}::1:20")
      expect(described_class.new(options.merge(tbs: 'w')).cache_key).to eq("#{affiliate.id}:element::#{since_a_week_ago}:1:10")
      expect(described_class.new(options.merge(since_date: '10/1/2012', until_date: '10/31/2012')).cache_key).to eq("#{affiliate.id}:element::2012-10-01..2012-10-31:1:10")
    end
  end

  describe '#as_json' do
    let(:expected_keys) do
      %w[body contributor created_at description guid id link unsafe_properties
         published_at publisher rss_feed_url_id subject title updated_at properties]
    end

    it 'contains all attributes' do
      search = described_class.new(affiliate: affiliate, channel: rss_feeds(:white_house_blog))
      search.run
      expect(search.as_json[:results].first.keys).to match_array(expected_keys)
    end
  end
end
