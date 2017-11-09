Redmine "Custom Query Share" Plugin
=======================

The Plugins aims at providing some user specific customization in redmine.

* Custom Query can be Private, Shared with users with specific Roles or Public,
The plugin provide another option "to selected users",
This allows selections of Project member users and groups and the query will be
accessible only for these members.

![Redmine Query Sharing](redmine_query_share.jpg "Redmine Query Share")

The plugin settings :

![Custom Query Settings](settings.jpg "Redmine Query Share Settings")

* Settings :

> Enable Query Sharing

>> Enables this plugin.

> User Selection Limit

>> The selection of users in the combo list is difficult when there are huge number
of users in the project. To give advanced flexibility to the users the limit is provided.
If the project members are within this range a default combo list will be shown.

>> ![Custom Query User Selection 1](user_list.jpg "Redmine User selection 1")

>> If the project members are beyond this limit a text field is shown,

>> ![Custom Query User Selection 2](user_textfield.jpg "Redmine User selection 2")

> Non Project group to show

>> By default the project member groups and members are shown, This option allow the
User groups flagged with a boolean custom field to be included automatically in all the projects.

>> ![Create Group Custom field](user_group_cf.jpg "User group custom field.")

>> Select this custom field option in the plugin settings. All the user groups defined
with this option checked will automatically included in all the projects.

Tested as compatible with Redmine v3.4.x