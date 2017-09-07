# MMT-586

require 'rails_helper'

describe 'Changing or Removing System Identity Permissions' do
  before :all do
    @group_response = create_group(
      name: 'Test System Permissions Group 2',
      description: 'Group to test system permissions',
      provider_id: nil,
      admin: true
    )

    # wait_for_cmr

    system_perm_1 = {
      'group_permissions' => [{
        'group_id'    => @group_response['concept_id'],
        'permissions' => %w(update)
      }],
      'system_identity' => {
        'target' => 'SYSTEM_CALENDAR_EVENT'
      }
    }

    system_perm_2 = {
      'group_permissions' => [{
        'group_id'    => @group_response['concept_id'],
        'permissions' => %w(create)
      }],
      'system_identity' => {
        'target' => 'SYSTEM_INITIALIZER'
      }
    }

    system_perm_3 = {
      'group_permissions' => [{
        'group_id'    => @group_response['concept_id'],
        'permissions' => %w(create delete)
      }],
      'system_identity' => {
        'target' => 'SYSTEM_OPTION_DEFINITION'
      }
    }

    permissions = [system_perm_1, system_perm_2, system_perm_3]
    permissions.each { |perm| cmr_client.add_group_permissions(perm, 'access_token_admin') }

    # wait_for_cmr
  end

  after :all do
    permissions_options = {
      'page_size' => 50,
      'permitted_group' => @group_response['concept_id']
    }
    permissions_response_items = cmr_client.get_permissions(permissions_options, 'access_token_admin').body.fetch('items', [])

    permissions_response_items.each { |perm_item| cmr_client.delete_permission(perm_item['concept_id'], 'access_token_admin') }

    delete_group(concept_id: @group_response['concept_id'], admin: true)
  end

  context 'when visiting the system object permissions page for a system group' do
    before do
      login_admin

      visit edit_system_identity_permission_path(@group_response['concept_id'])
    end

    it 'has the correct permissions checked' do
      expect(page).to have_checked_field('system_permissions_SYSTEM_CALENDAR_EVENT_', with: 'update')
      expect(page).to have_checked_field('system_permissions_SYSTEM_INITIALIZER_', with: 'create')
      expect(page).to have_checked_field('system_permissions_SYSTEM_OPTION_DEFINITION_', with: 'create')
      expect(page).to have_checked_field('system_permissions_SYSTEM_OPTION_DEFINITION_', with: 'delete')
    end

    context 'when changing and removing system permissions' do
      before do
        check('system_permissions_SYSTEM_CALENDAR_EVENT_', option: 'create')
        check('system_permissions_SYSTEM_CALENDAR_EVENT_', option: 'delete')

        uncheck('system_permissions_SYSTEM_INITIALIZER_', option: 'create')
        uncheck('system_permissions_SYSTEM_OPTION_DEFINITION_', option: 'delete')

        within '.system-permissions-form' do
          click_on 'Submit'
        end

        # wait_for_cmr
      end

      it 'displays a success message and no error message on the index page' do
        expect(page).to have_content('System Object Permissions')
        expect(page).to have_content('Click on a System Group to access the system object permissions for that group.')

        expect(page).to have_content('System Object Permissions were saved.')
        expect(page).to have_no_content('permissions were unable to be saved.')
      end
    end
  end
end
