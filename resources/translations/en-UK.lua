LANGUAGE = {

    formats = {
        date = {
            "%Y/%m/%d"
        },
        time = {
            "%H:%i:%s"
        }
    },

    -- List of all the translations
    translations = {

        -- The key of each element is the text in parameter of babel.translate()
        ['Hello world'] = "Hello world",
        ['My name is %name%'] = "My name is %name%"

    }

}
return LANGUAGE