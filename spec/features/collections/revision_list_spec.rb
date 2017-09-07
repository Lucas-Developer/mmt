# MMT-87, MMT-88, MMT-21

require 'rails_helper'

describe 'Revision list', js: true do
  context 'when viewing a published collection' do
    before do
      login

      ingest_response, @concept_response = publish_collection_draft(revision_count: 2)

      visit collection_path(ingest_response['concept-id'])
    end

    it 'displays the number of revisions' do
      expect(page).to have_content('Revisions (2)')
    end

    context 'when clicking on the revision link' do
      before do
        # wait_for_cmr
        click_on 'Revisions'
      end

      it 'displays the revision page' do
        expect(page).to have_content('Revision History')
      end

      it 'displays the collection entry title' do
        expect(page).to have_content(@concept_response.body['EntryTitle'])
      end

      it 'displays when the revision was made' do
        expect(page).to have_content(today_string, count: 2)
      end

      it 'displays what user made the revision' do
        expect(page).to have_content('typical', count: 2)
      end

      it 'displays the correct phrasing for reverting records' do
        expect(page).to have_content('Revert to this Revision', count: 1)
      end

      context 'when viewing an old revision' do
        link_text = 'You are viewing an older revision of this collection. Click here to view the latest published version.'
        before do
          all('a', text: 'View').last.click
        end

        it 'displays a message that the revision is old' do
          expect(page).to have_link(link_text)
        end

        context 'when clicking the message' do
          before do
            click_on link_text
          end

          it 'displays the latest revision to the user' do
            expect(page).to have_no_link(link_text)
          end
        end
      end
    end

    context 'when searching for the collection' do
      before do
        full_search(keyword: @concept_response.body['EntryTitle'], provider: 'MMT_2')
      end

      it 'only displays the latest revision' do
        within '#collection-search-results' do
          expect(page).to have_content(@concept_response.body['EntryTitle'], count: 1)
        end
      end
    end
  end
end
