# audiobookshelf

## Regenerate `install.yaml`

Chart version and render flags live in [`helm.yaml`](helm.yaml).

```bash
./scripts/render-helm.sh audiobookshelf
```


Host data lives under `/mnt/seagate/audiobookshelf` on the node, mounted at `/data` in the pod. App config and metadata use `CONFIG_PATH=/data/config` and `METADATA_PATH=/data/metadata`; add library folders under the same host tree (for example `/mnt/seagate/audiobookshelf/audiobooks`) and point Audiobookshelf at the matching path inside the container (for example `/data/audiobooks`).
