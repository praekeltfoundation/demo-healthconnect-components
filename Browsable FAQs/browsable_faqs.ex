stack ContentRepo, "Browsable FAQs with Content Repo integraion" do
    card MainMenu, "Main Menu" do
        # The main menu is a special case, since it is not a specific content page, but rather a
        # collection of content indexes, that we can select using a specific tag
        # CONFIG: You can modify the content repo URL here to point to a different content repo instance
        contentrepo_url = "https://content-repo-api.qa.momconnect.co.za"
        # CONFIG: You can modify the main menu tag here, to select for a different tag that represents your main menu
        main_menu_tag = "mainmenu"
        # Get and process all of the items for the menu list
        menu_data = get(
            "@contentrepo_url/api/v2/pages/",
            query: [
                ["tag", "@main_menu_tag"]
            ]
        )
        # TODO: Due to a bug in build, we cannot have a numeric here, so we concatenate a "." here, 
        #       and remove it when we need to use the ID. Remove when bug is fixed
        menu_items = map(menu_data.body.results, &[concatenate(".", &1.id), &1.title])
        # Display the list of items to the user
        selected_menu = list("Select a topic", ContentMenu, menu_items)
        # This can also be quick reply buttons, if you're sure that you'll always have <=3 of them
        # selected_menu = buttons(ContentMenu, menu_items)
        text("Please select a topic that you are interested in")
    end

    card ContentMenu, "@content_menu_data.body.title" do
        # Now that they've selected which menu they want to view, they need to choose a topic from that menu
        # This is another special case, as each menu doesn't have any content associated with it

        # First we get the data for this page, this is useful for referring back to it
        # Note that we don't query for a channel specific data, because it doesn't exist
        # TODO: remove this substitute once build bug is fixed
        #       we need this concatenate because substitute breaks on a number
        selected_menu = substitute(concatenate(".", selected_menu), ".", "")
        content_menu_data = get(
            "@contentrepo_url/api/v2/pages/@selected_menu/"
        )
        # Then we get all the children to give to the user to select from
        content_menu_children_data = get(
            "@contentrepo_url/api/v2/pages/",
            query: [
                ["child_of", "@selected_menu"]
            ]
        )
        # TODO: Remove concatenate once build bug is fixed
        content_menu_items = map(content_menu_children_data.body.results, &[concatenate(".", &1.id), &1.title])
        selected_content = list("Select a topic", FetchContent, content_menu_items)
        # This can also be quick reply buttons, if you're sure that you'll always have <=3 of them
        # selected_content = buttons(FetchContent, content_menu_items)
        text("Please select a topic that you are interested in")
    end

    card FetchContent, then: DisplayContent do
        # Fetch the piece of content that we want to display to the user
        # We do this in a separate card, because we want to display it differently depending on what is returned
        # TODO: Remove substitute once build bug is fixed
        #       we need this concatenate because substitute breaks on a number
        selected_content = substitute(concatenate(".", selected_content), ".", "")
        content_data = get(
            "@contentrepo_url/api/v2/pages/@selected_content/",
            query: [
                # CONFIG: set the type of channel here
                ["whatsapp", "true"]
            ]
        )
    end

    card DisplayContent when content_data.body.has_children do
        # If there are children, then give the user a list of options to choose from
        content_children_data = get(
            "@contentrepo_url/api/v2/pages/",
            query: [
                ["child_of", "@selected_content"]
            ]
        )
        # TODO: Remove concatenate once build bug is fixed
        content_children = map(content_children_data.body.results, &[concatenate(".", &1.id), &1.title])
        selected_content = list("Select a topic", FetchContent, content_children)
        # Different channel types have different locations for the message, so this might need to be changed
        text("@content_data.body.body.text.value.message")
    end

    card DisplayContent do
        # If there aren't any children, then just display the content
        # Display buttons for navigation
        # The user can go back to the top, or to after their main menu selection, or to the previous level
        buttons([MainMenu, ContentMenu, ParentContent])
        # Different channel types have different locations for the message, so this might need to be changed
        text("@content_data.body.body.text.value.message")
    end

    card ParentContent, "@content_data.body.meta.parent.title", then: FetchContent do
        # Set the current content to the parent, and then load it
        selected_content = content_data.body.meta.parent.id
    end
end
