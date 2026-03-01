<?php

require_once __DIR__ . '/vendor/autoload.php';

Mage::app();

// Create a "Demo" role
$role = Mage::getModel('admin/role');
$role->setData([
    'role_type'  => 'G',
    'role_name'  => 'Demo',
    'parent_id'  => 0,
    'tree_level' => 1,
    'sort_order' => 0,
]);
$role->save();
echo "Created role 'Demo' with ID: {$role->getId()}\n";

// Get all available ACL resources and exclude admin/system
$allResources = Mage::getModel('admin/roles')->getResourcesList2D();
$denied = [
    'admin/system',
];
$allowedResources = array_filter($allResources, function ($resource) use ($denied) {
    foreach ($denied as $prefix) {
        if ($resource === $prefix || str_starts_with($resource, $prefix . '/')) {
            return false;
        }
    }
    return true;
});

$rules = Mage::getModel('admin/rules');
$rules->setRoleId($role->getId());
$rules->setResources(array_values($allowedResources));
$rules->saveRel();
echo "Granted permissions (excluding System) to role\n";

// Create the demo admin user
$user = Mage::getModel('admin/user');
$user->setData([
    'firstname' => 'Demo',
    'lastname'  => 'User',
    'email'     => 'demo@mahocommerce.com',
    'username'  => 'demo',
    'password'  => 'demo1234demo1234',
    'is_active' => 1,
]);

$errors = $user->validate();
if (is_array($errors)) {
    foreach ($errors as $error) {
        echo "Validation error: $error\n";
    }
    exit(1);
}

$user->save();
echo "Created user 'demo' with ID: {$user->getId()}\n";

// Assign the role to the user
$user->setRoleIds([$role->getId()]);
$user->saveRelations();
echo "Assigned 'Demo' role to user\n";

echo "\nDone! Login with username: demo / password: demo1234demo1234\n";
