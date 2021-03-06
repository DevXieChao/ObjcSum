//
//  PropertyAndVariableDemo.m
//  ObjcSum
//
//  Created by sihuan on 2016/6/27.
//  Copyright © 2016年 sihuan. All rights reserved.
//

#import "PropertyAndVariableDemo.h"
#import "MyClass1.h"
#import <objc/runtime.h>

@implementation PropertyAndVariableDemo

+ (void)launch {
    [self typeEncodeDemo];
    [self ivarAndPropertyDemo];
}

#pragma mark - ## 类型编码(Type Encoding)
/**
 <mark>作为对Runtime的补充，编译器将每个方法的返回值和参数类型编码为一个字符串，并将其与方法的selector关联在一起。
 任何可以作为sizeof()操作参数的类型都可以用于@encode()。
 */
+ (void)typeEncodeDemo {
    float a[] = { 1, 2, 3};
    NSLog(@"array encoding type: %s", @encode(typeof(a)));
    //array encoding type: [3f]
}

+ (void)ivarAndPropertyDemo {
    Class cls = MyClass1.class;
    unsigned int count = 0;
    
    NSLog(@"----------------------成员变量操作函数----------------------");
    /*
     // 获取成员变量名
     const char * ivar_getName ( Ivar v );
     
     // 获取成员变量类型编码
     const char * ivar_getTypeEncoding ( Ivar v );
     
     // 获取成员变量的偏移量
     ptrdiff_t ivar_getOffset ( Ivar v );
     */
    Ivar *ivars = class_copyIvarList(cls, &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        NSLog(@"ivar name = %s, code = %s, offset = %td", ivar_getName(ivar), ivar_getTypeEncoding(ivar), ivar_getOffset(ivar));
        //ivar name = _instance2, code = @"NSString", offset = 16
    }
    free(ivars);
    
    NSLog(@"----------------------属性操作函数----------------------");
    
    /**
     // 获取属性名
     const char * property_getName ( objc_property_t property );
     
     // 获取属性特性描述字符串
     const char * property_getAttributes ( objc_property_t property );
     
     // 获取属性中指定的特性
     char * property_copyAttributeValue ( objc_property_t property, const char *attributeName );
     
     // 获取属性的特性列表
     objc_property_attribute_t * property_copyAttributeList ( objc_property_t property, unsigned int *outCount );

     */
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    for (int i = 0; i < count; i++) {
        objc_property_t p = properties[i];
        NSLog(@"property name = %s, property attributes = %s", property_getName(p), property_getAttributes(p));
        //property name = interger, property attributes = Tq,N,V_interger
        
        unsigned int pCount = 0;
        objc_property_attribute_t *attrs = property_copyAttributeList(p, &pCount);
        for (int j = 0; j < pCount; j ++) {
            objc_property_attribute_t attr = attrs[j];
            NSLog(@"objc_property_attribute_t name = %s, value = %s", attr.name, attr.value);
        }
        free(attrs);
    }
    free(properties);
}

@end

#pragma mark - ## 成员变量、属性

//Runtime中关于成员变量和属性的相关数据结构并不多，只有三个，并且都很简单。不过还有个非常实用但可能经常被忽视的特性，即关联对象

/**
 ### 1. 基础数据类型
 
 #### Ivar
 
 Ivar是表示实例变量的类型，其实际是一个指向objc_ivar结构体的指针，其定义如下：
 */
//typedef struct objc_ivar *Ivar;
struct yy_objc_ivar {
    char *ivar_name;// 变量名
    char *ivar_type;// 变量类型
    int ivar_offset;// 基地址偏移字节
    int space;
};

/**
 #### `objc_property_t`
 
 `objc_property_t`是表示Objective-C声明的属性的类型，其实际是指向objc_property结构体的指针，其定义如下：
 
	typedef struct objc_property *objc_property_t;
 
 #### `objc_property_attribute_t`
 
 `objc_property_attribute_t`定义了属性的特性(attribute)，它是一个结构体，定义如下：
 */
typedef struct {
    const char *name; // 特性名
    const char *value;// 特性值
} yy_objc_property_attribute_t;
















