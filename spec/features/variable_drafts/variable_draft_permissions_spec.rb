require 'rails_helper'

describe 'Variable draft permissions' do
  let(:name)      { 'Draft Title' }
  let(:long_name) { 'Tropical Forest Observation Record' }
  let(:provider)  { 'MMT_2' }

  before do
    login

    create(:full_variable_draft, draft_entry_title: long_name, draft_short_name: name, provider_id: provider)
  end

  let(:draft) { Draft.first }

  context 'when the draft provider is in the users available providers', js: true do
    before do
      user = User.first
      user.provider_id = 'MMT_1'
      user.available_providers = %w(MMT_1 MMT_2)
      user.save
    end

    context 'when trying to visit the draft page directly' do
      before do
        visit variable_draft_path(draft)
      end

      it 'displays the variable draft show page' do
        within '.eui-breadcrumbs' do
          expect(page).to have_content('Variable Drafts')
          expect(page).to have_content("#{name}")
        end

        within 'main header' do
          expect(page).to have_css('h2', text: "#{name}")
          expect(page).to have_content(long_name)
        end
      end

      it 'does not display the variable draft preview' do
        expect(page).to have_no_content('Publish Variable Draft')
        expect(page).to have_no_content('Delete Variable Draft')
        expect(page).to have_no_content('Metadata Fields')
        expect(page).to have_no_content('Variable Information')
        expect(page).to have_no_content('Dimensions')
      end

      it 'displays a banner message to change provider the Not Current Provider content' do
        expect(page).to have_css('.eui-banner--warn')
        within '.eui-banner--warn' do
          expect(page).to have_content('You need to change your current provider to show this Variable Draft')
        end

        expect(page).to have_content('Not Current Provider')
        expect(page).to have_content('It appears you need to change your current provider to access to this content.')
      end

      context 'when clicking on warning banner link' do
        before do
          click_on 'You need to change your current provider to show this Variable Draft'

          wait_for_ajax
        end

        it 'switches the provider context' do
          expect(User.first.provider_id).to eq('MMT_2')
        end

        it 'displays the variable draft show page' do
          within '.eui-breadcrumbs' do
            expect(page).to have_content('Variable Drafts')
            expect(page).to have_content("#{name}")
          end

          within 'main header' do
            expect(page).to have_css('h2', text: "#{name}")
            expect(page).to have_content(long_name)
          end
        end

        it 'displays the variable draft preview information' do
          within '.eui-breadcrumbs' do
            expect(page).to have_content('Variable Drafts')
            expect(page).to have_content('Draft Title')
          end

          expect(page).to have_content(name)
          expect(page).to have_content('Publish Variable Draft')
          expect(page).to have_content('Delete Variable Draft')
        end
      end
    end

    context 'when trying to visit the edit draft variable information page directly' do
      before do
        visit edit_variable_draft_path(draft, 'variable_information')
      end

      it 'displays the variable draft show page' do
        within '.eui-breadcrumbs' do
          expect(page).to have_content('Variable Drafts')
          expect(page).to have_content("#{name}")
        end

        within 'main header' do
          expect(page).to have_css('h2', text: "#{name}")
          expect(page).to have_content(long_name)
        end
      end

      it 'does not display the variable draft preview' do
        expect(page).to have_no_content('Publish Variable Draft')
        expect(page).to have_no_content('Delete Variable Draft')
        expect(page).to have_no_content('Metadata Fields')
        expect(page).to have_no_content('Variable Information')
        expect(page).to have_no_content('Dimensions')
      end

      it 'displays a banner message to change provider the Not Current Provider content' do
        expect(page).to have_css('.eui-banner--warn')
        within '.eui-banner--warn' do
          expect(page).to have_content('You need to change your current provider to edit this Variable Draft')
        end

        expect(page).to have_content('Not Current Provider')
        expect(page).to have_content('It appears you need to change your current provider to access to this content.')
      end

      context 'when clicking on warning banner link' do
        before do
          click_on 'You need to change your current provider to edit this Variable Draft'

          wait_for_ajax
        end

        it 'switches the provider context' do
          expect(User.first.provider_id).to eq('MMT_2')
        end

        it 'goes to the edit draft variable information page' do
          within '.eui-breadcrumbs' do
            expect(page).to have_content('Variable Information')
          end
          within 'header .collection-basics' do
            expect(page).to have_content('Variable Information')
          end
          expect(page).to have_field('Name')
          expect(page).to have_field('Long Name')
        end
      end
    end
  end

  context 'when the draft provider is not in the user available providers' do
    before do
      user = User.first
      user.provider_id = 'LARC'
      user.available_providers = ['LARC']
      user.save
    end

    context 'when trying to visit the draft page directly' do
      before do
        visit variable_draft_path(draft)
      end

      it 'redirects to the Manage Variables page' do
        within 'main header' do
          expect(page).to have_css('h2.current', text: 'Manage Variables')
        end
      end

      it 'displays a no permissions banner message' do
        expect(page).to have_css('.eui-banner--danger')
        expect(page).to have_content('It appears you do not have access to view the Variable Draft for this provider.')
        expect(page).to have_content('If you feel you should have access, please check with your provider manager or ensure you are logged into the correct provider.')
      end
    end

    context 'when trying to visit the edit draft page directly' do
      before do
        visit edit_variable_draft_path(draft)
      end

      it 'redirects to the Manage Variables page' do
        within 'main header' do
          expect(page).to have_css('h2.current', text: 'Manage Variables')
        end
      end

      it 'displays a no permisssions banner message' do
        expect(page).to have_css('.eui-banner--danger')
        expect(page).to have_content('It appears you do not have access to edit the Variable Draft for this provider.')
        expect(page).to have_content('If you feel you should have access, please check with your provider manager or ensure you are logged into the correct provider.')
      end
    end
  end
end
