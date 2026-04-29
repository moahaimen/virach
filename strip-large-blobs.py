def callback(blob, metadata):
    if blob.rawsize > 20 * 1024 * 1024:  # 20MB
        return None
    return blob


