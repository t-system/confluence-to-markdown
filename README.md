# Confluence to Markdown converter that works right now but probably not in a few months time

Convert [Confluence HTML export](#conflhowto) to Markdown


## Requirements

Setup
Clone and run `yarn` in root directory

## Usage

It's a good idea to create an 'output' folder somewhere to target with the `pathResult` parameter (where the output files will go)

In the converter's directory:

```
npm run start <pathResource> <pathResult> <runPostProcessScript>
```

### Parameters

parameter | description
--- | ---
`<pathResource>` | File or directory to convert with extracted Confluence export
`<pathResult>` | Directory to where the output will be generated to. Defaults to current working directory
<runPostProcessScript> | OPTIONAL 'true' to run the file location cleanup and link fix script, 'false' or omitted to not run the script 

### Optional

To run the Post Process Script directly:

`bash <pathToUpdateLinksScript> <pathResult> <spaceName>`

### Parameters

| parameter                   | description                                                  |
| --------------------------- | ------------------------------------------------------------ |
| `<pathToUpdateLinksScript>` | Absolute path to `update-links.sh` in the `./src` folder of the project |
| `<pathResult>`              | Directory to where the output will be generated to. Defaults to current working directory |
| <spaceName>                 | Name of the root confluence space                            |

### 
