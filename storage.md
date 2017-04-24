# Lý thuyết

+ Như trong phần concept, để tích hợp storage vào kubernetes cần config storageclass, persistence-volume, persistence-volume-sclaim
+ Các Secret sẽ dùng để lưu thông tin password của phần authentication.
+ Các volume cần dược mount lên worker node, sau đó sẽ được mount vào trong Pod.
+ Với các cloud provider, volume sẽ được mount vào trong worker node qua api. Ví dụ cinder-volume cần qua api openstack.
+ Để tích hợp được với các storage như ceph, scaleio, openvstorage cần cài đặt các client lên và mount được volume lên workder node.
+ Để tích hợp với openstack cần cung cấp thông tin xác thực tới openstack : auth_url, username, password, project-name, domain-name ...
+ Với các Storage kubernetes không hỗ trợ trực tiếp có thể dùng qua Flocker
+ PersisteceVolume có thể chia làm 2 loại
    + Dynamic Provisioning : với loại này volume ở dạng template, mặc định sẽ được xóa đi nếu Pod bị xóa.
    + Static Provisioning : volume này sẽ không bị xóa khi Pod bị xóa.

# [CEPH](integrate_ceph.md)

# [OpenStack Cinder (cloud-provider)](integrate_openstack_cinder.md)

# [Storage flocker](integrate_flocker.md)

# [ScaleioIO](integrate_scaleio_1.6.md)