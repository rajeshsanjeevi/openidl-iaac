ui = true
listener "tcp" {
    address = "vault-carrier.dev.internal.aaiscarrierdemo.com
    cluster_addr = "{{ vault_cluster_address }}"
    tls_disable = "true"
}
seal "awskms" {
    kms_key_id = " {{ vault_kms_key_id }}"
    region = " {{ vault_kms_region }} "
}