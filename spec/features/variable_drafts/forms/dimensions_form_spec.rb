require 'rails_helper'

describe 'Dimensions Form', js: true do
  before do
    login
  end

  context 'When viewing the form with no stored values' do
    before do
      draft = create(:empty_variable_draft, user: User.where(urs_uid: 'testuser').first)
      visit edit_variable_draft_path(draft, 'dimensions')
    end

    it 'displays the correct title' do
      within '.umm-form' do
        expect(page).to have_content('Dimensions')
      end
    end

    it 'displays the form title in the breadcrumbs' do
      within '.eui-breadcrumbs' do
        expect(page).to have_content('Variable Drafts')
        expect(page).to have_content('Dimensions')
      end
    end

    it 'displays a button to add another element' do
      expect(page).to have_selector(:link_or_button, 'Add another Dimension')
    end

    it 'has three required labels' do
      expect(page).to have_selector('label.eui-required-o', count: 3)
    end

    context 'When clicking `Previous` without making any changes' do
      before do
        within '.nav-top' do
          click_button 'Previous'
        end

        click_on 'Yes'
      end

      it 'saves the draft and loads the previous form' do
        within '.eui-banner--success' do
          expect(page).to have_content('Variable Draft Updated Successfully!')
        end

        within '.eui-breadcrumbs' do
          expect(page).to have_content('Variable Drafts')
          expect(page).to have_content('Fill Values')
        end

        within '.umm-form' do
          expect(page).to have_content('Fill Values')
        end

        within '.nav-top' do
          expect(find(:css, 'select[name=jump_to_section]').value).to eq('fill_values')
        end

        within '.nav-bottom' do
          expect(find(:css, 'select[name=jump_to_section]').value).to eq('fill_values')
        end
      end
    end

    context 'When clicking `Next` without making any changes' do
      before do
        within '.nav-top' do
          click_on 'Next'
        end

        click_on 'Yes'
      end

      it 'saves the draft and loads the next form' do
        within '.eui-banner--success' do
          expect(page).to have_content('Variable Draft Updated Successfully!')
        end

        within '.eui-breadcrumbs' do
          expect(page).to have_content('Variable Drafts')
          expect(page).to have_content('Variable Characteristics')
        end

        within '.umm-form' do
          expect(page).to have_content('Variable Characteristics')
        end

        within '.nav-top' do
          expect(find(:css, 'select[name=jump_to_section]').value).to eq('variable_characteristics')
        end

        within '.nav-bottom' do
          expect(find(:css, 'select[name=jump_to_section]').value).to eq('variable_characteristics')
        end
      end
    end

    context 'When clicking `Save` without making any changes' do
      before do
        within '.nav-top' do
          click_button 'Save'
        end

        click_on 'Yes'
      end

      it 'saves the draft and reloads the form' do
        within '.eui-banner--success' do
          expect(page).to have_content('Variable Draft Updated Successfully!')
        end

        within '.eui-breadcrumbs' do
          expect(page).to have_content('Variable Drafts')
          expect(page).to have_content('Dimensions')
        end

        within '.umm-form' do
          expect(page).to have_content('Dimensions')
        end

        within '.nav-top' do
          expect(find(:css, 'select[name=jump_to_section]').value).to eq('dimensions')
        end

        within '.nav-bottom' do
          expect(find(:css, 'select[name=jump_to_section]').value).to eq('dimensions')
        end
      end
    end

    context 'When selecting the previous form from the navigation dropdown' do
      before do
        within '.nav-top' do
          select 'Fill Values', from: 'Save & Jump To:'
        end

        click_on 'Yes'
      end

      it 'saves the draft and loads the previous form' do
        within '.eui-banner--success' do
          expect(page).to have_content('Variable Draft Updated Successfully!')
        end

        within '.eui-breadcrumbs' do
          expect(page).to have_content('Variable Drafts')
          expect(page).to have_content('Fill Values')
        end

        within '.umm-form' do
          expect(page).to have_content('Fill Values')
        end

        within '.nav-top' do
          expect(find(:css, 'select[name=jump_to_section]').value).to eq('fill_values')
        end

        within '.nav-bottom' do
          expect(find(:css, 'select[name=jump_to_section]').value).to eq('fill_values')
        end
      end
    end

    context 'When selecting the next form from the navigation dropdown' do
      before do
        within '.nav-top' do
          select 'Variable Characteristics', from: 'Save & Jump To:'
        end

        click_on 'Yes'
      end

      it 'saves the draft and loads the next form' do
        within '.eui-banner--success' do
          expect(page).to have_content('Variable Draft Updated Successfully!')
        end

        within '.eui-breadcrumbs' do
          expect(page).to have_content('Variable Drafts')
          expect(page).to have_content('Variable Characteristics')
        end

        within '.umm-form' do
          expect(page).to have_content('Variable Characteristics')
        end

        within '.nav-top' do
          expect(find(:css, 'select[name=jump_to_section]').value).to eq('variable_characteristics')
        end

        within '.nav-bottom' do
          expect(find(:css, 'select[name=jump_to_section]').value).to eq('variable_characteristics')
        end
      end
    end
  end

  context 'When viewing the form with 1 stored value' do
    before do
      draft_dimensions = [{
        'Name': 'Sampling time and depth',
        'Size': 3000
      }]
      draft = create(:empty_variable_draft, user: User.where(urs_uid: 'testuser').first, draft: { 'Dimensions': draft_dimensions })
      visit edit_variable_draft_path(draft, 'dimensions')
    end

    it 'displays one populated form' do
      expect(page).to have_css('.multiple-item', count: 1)
    end

    it 'displays the correct values in the form' do
      expect(page).to have_field('variable_draft_draft_dimensions_0_name', with: 'Sampling time and depth')
      expect(page).to have_field('variable_draft_draft_dimensions_0_size', with: '3000')
    end

    context 'When clicking `Previous` without making any changes' do
      before do
        within '.nav-top' do
          click_button 'Previous'
        end
      end

      it 'saves the draft and loads the previous form' do
        within '.eui-banner--success' do
          expect(page).to have_content('Variable Draft Updated Successfully!')
        end

        within '.eui-breadcrumbs' do
          expect(page).to have_content('Variable Drafts')
          expect(page).to have_content('Fill Values')
        end

        within '.umm-form' do
          expect(page).to have_content('Fill Values')
        end

        within '.nav-top' do
          expect(find(:css, 'select[name=jump_to_section]').value).to eq('fill_values')
        end

        within '.nav-bottom' do
          expect(find(:css, 'select[name=jump_to_section]').value).to eq('fill_values')
        end
      end
    end

    context 'When clicking `Next` without making any changes' do
      before do
        within '.nav-top' do
          click_on 'Next'
        end
      end

      it 'saves the draft and loads the next form' do
        within '.eui-banner--success' do
          expect(page).to have_content('Variable Draft Updated Successfully!')
        end

        within '.eui-breadcrumbs' do
          expect(page).to have_content('Variable Drafts')
          expect(page).to have_content('Variable Characteristics')
        end

        within '.umm-form' do
          expect(page).to have_content('Variable Characteristics')
        end

        within '.nav-top' do
          expect(find(:css, 'select[name=jump_to_section]').value).to eq('variable_characteristics')
        end

        within '.nav-bottom' do
          expect(find(:css, 'select[name=jump_to_section]').value).to eq('variable_characteristics')
        end
      end
    end

    context 'When clicking `Save` without making any changes' do
      before do
        within '.nav-top' do
          click_button 'Save'
        end
      end

      it 'saves the draft and reloads the form' do
        within '.eui-banner--success' do
          expect(page).to have_content('Variable Draft Updated Successfully!')
        end

        within '.eui-breadcrumbs' do
          expect(page).to have_content('Variable Drafts')
          expect(page).to have_content('Dimensions')
        end

        within '.umm-form' do
          expect(page).to have_content('Dimensions')
        end

        within '.nav-top' do
          expect(find(:css, 'select[name=jump_to_section]').value).to eq('dimensions')
        end

        within '.nav-bottom' do
          expect(find(:css, 'select[name=jump_to_section]').value).to eq('dimensions')
        end
      end

      it 'displays the correct values in the form' do
        expect(page).to have_field('variable_draft_draft_dimensions_0_name', with: 'Sampling time and depth')
        expect(page).to have_field('variable_draft_draft_dimensions_0_size', with: '3000')
      end
    end
  end

  context 'When viewing the form with 2 stored values' do
    before do
      draft_dimensions = [{
        'Name': 'Sampling time and depth',
        'Size': 3000
      }, {
        'Name': 'Lizard Herp Doc Pop',
        'Size': 2020
      }]
      draft = create(:empty_variable_draft, user: User.where(urs_uid: 'testuser').first, draft: { 'Dimensions': draft_dimensions })
      visit edit_variable_draft_path(draft, 'dimensions')
    end

    it 'displays one populated form' do
      expect(page).to have_css('.multiple-item', count: 2)
    end

    it 'displays the correct values in the form' do
      expect(page).to have_field('variable_draft_draft_dimensions_0_name', with: 'Sampling time and depth')
      expect(page).to have_field('variable_draft_draft_dimensions_0_size', with: '3000')

      expect(page).to have_field('variable_draft_draft_dimensions_1_name', with: 'Lizard Herp Doc Pop')
      expect(page).to have_field('variable_draft_draft_dimensions_1_size', with: '2020')
    end

    context 'When clicking `Previous` without making any changes' do
      before do
        within '.nav-top' do
          click_button 'Previous'
        end
      end

      it 'saves the draft and loads the previous form' do
        within '.eui-banner--success' do
          expect(page).to have_content('Variable Draft Updated Successfully!')
        end

        within '.eui-breadcrumbs' do
          expect(page).to have_content('Variable Drafts')
          expect(page).to have_content('Fill Values')
        end

        within '.umm-form' do
          expect(page).to have_content('Fill Values')
        end

        within '.nav-top' do
          expect(find(:css, 'select[name=jump_to_section]').value).to eq('fill_values')
        end

        within '.nav-bottom' do
          expect(find(:css, 'select[name=jump_to_section]').value).to eq('fill_values')
        end
      end
    end

    context 'When clicking `Next` without making any changes' do
      before do
        within '.nav-top' do
          click_on 'Next'
        end
      end

      it 'saves the draft and loads the next form' do
        within '.eui-banner--success' do
          expect(page).to have_content('Variable Draft Updated Successfully!')
        end

        within '.eui-breadcrumbs' do
          expect(page).to have_content('Variable Drafts')
          expect(page).to have_content('Variable Characteristics')
        end

        within '.umm-form' do
          expect(page).to have_content('Variable Characteristics')
        end

        within '.nav-top' do
          expect(find(:css, 'select[name=jump_to_section]').value).to eq('variable_characteristics')
        end

        within '.nav-bottom' do
          expect(find(:css, 'select[name=jump_to_section]').value).to eq('variable_characteristics')
        end
      end
    end

    context 'When clicking `Save` without making any changes' do
      before do
        within '.nav-top' do
          click_button 'Save'
        end
      end

      it 'saves the draft and reloads the form' do
        within '.eui-banner--success' do
          expect(page).to have_content('Variable Draft Updated Successfully!')
        end

        within '.eui-breadcrumbs' do
          expect(page).to have_content('Variable Drafts')
          expect(page).to have_content('Dimensions')
        end

        within '.umm-form' do
          expect(page).to have_content('Dimensions')
        end

        within '.nav-top' do
          expect(find(:css, 'select[name=jump_to_section]').value).to eq('dimensions')
        end

        within '.nav-bottom' do
          expect(find(:css, 'select[name=jump_to_section]').value).to eq('dimensions')
        end
      end

      it 'displays the correct values in the form' do
        expect(page).to have_field('variable_draft_draft_dimensions_0_name', with: 'Sampling time and depth')
        expect(page).to have_field('variable_draft_draft_dimensions_0_size', with: '3000')

        expect(page).to have_field('variable_draft_draft_dimensions_1_name', with: 'Lizard Herp Doc Pop')
        expect(page).to have_field('variable_draft_draft_dimensions_1_size', with: '2020')
      end
    end
  end
end
