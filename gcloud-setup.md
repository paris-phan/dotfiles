to set up gcloud configurations

```
brew install direnv

 direnv hook fish | source

 direnv allow

gcloud auth login

gcloud config configurations create greekcore
gcloud config configurations activate greekcore
gcloud config set account paris@greekcore.com
 
```