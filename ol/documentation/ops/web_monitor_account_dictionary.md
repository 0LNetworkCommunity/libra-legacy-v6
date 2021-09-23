# How to Configure Web Monitor Account Dictionary

## Why
You may be interested to identify account addresses displayed in the web monitor.

Web monitor supports a dictionary file to associate a note to every account address of your interest.
E.g.:![web monitor address note](https://user-images.githubusercontent.com/10797037/127385501-f6ec4b4a-e4bc-430c-b8c2-6be2d96293ae.png)


## How
Create a file named ```accounts-dictionary.json``` with the following structure example:
```
{
    "accounts": [
       { "note": "build a chain", "address": "88E74DFED34420F2AD8032148280A84B" },
       { "note": "save the world", "address": "4C613C2F4B1E67CA8D98A542EE3F59F5" }
    ]
}
```

## Where
The dictionary file must be placed in the validator /.0L folder. E.g.: ```$HOME/.0L/accounts-dictionary.json```

Once the file is deployed, the server will send the notes to the client.

