// ==========================================================================
// Project:  SproutCore Runtime
// Copyright: ©2011 Strobe Inc. and contributors.
// License:   Licensed under MIT license (see license.js)
// ==========================================================================

module('SC.alias');

function validateAlias(obj) {
  var get = SC.get;
  equals(get(obj, 'foo'), 'foo', 'obj.foo');
  equals(get(obj, 'bar'), 'foo', 'obj.bar should be a copy of foo');

  equals(get(obj, 'computedFoo'), 'cfoo', 'obj.computedFoo');
  equals(get(obj, 'computedBar'), 'cfoo', 'obj.computedBar should be a copy of computedFoo');

  equals(obj.fooMethod(), 'FOO', 'obj.fooMethod()');
  equals(obj.barMethod(), 'FOO', 'obj.barMethod should be a copy of foo');
}

test('copies the property values from another key when the mixin is applied', function() {

  var MyMixin = SC.Mixin.create({
    foo: 'foo',
    bar: SC.alias('foo'),

    computedFoo: SC.computed(function() {
      return 'cfoo';
    }),

    computedBar: SC.alias('computedFoo'),
    
    fooMethod: function() { return 'FOO'; },
    barMethod: SC.alias('fooMethod')
  });
  
  var obj = MyMixin.apply({});
  validateAlias(obj);
});

test('should follow aliases all the way down', function() {
  var MyMixin = SC.Mixin.create({
    bar: SC.alias('foo'), // put first to break ordered iteration
    baz: 'baz',
    foo: SC.alias('baz')
  });
  
  var obj = MyMixin.apply({});
  equals(SC.get(obj, 'bar'), 'baz', 'should have followed aliases');
});

test('should copy from other dependent mixins', function() {

  var BaseMixin = SC.Mixin.create({
    foo: 'foo',

    computedFoo: SC.computed(function() {
      return 'cfoo';
    }),

    fooMethod: function() { return 'FOO'; }
  });
  
  var MyMixin = SC.Mixin.create(BaseMixin, {
    bar: SC.alias('foo'),
    computedBar: SC.alias('computedFoo'),
    barMethod: SC.alias('fooMethod')
  });
  
  var obj = MyMixin.apply({});
  validateAlias(obj);
});

test('should copy from other mixins applied at same time', function() {

  var BaseMixin = SC.Mixin.create({
    foo: 'foo',

    computedFoo: SC.computed(function() {
      return 'cfoo';
    }),

    fooMethod: function() { return 'FOO'; }
  });
  
  var MyMixin = SC.Mixin.create({
    bar: SC.alias('foo'),
    computedBar: SC.alias('computedFoo'),
    barMethod: SC.alias('fooMethod')
  });
  
  var obj = SC.mixin({}, BaseMixin, MyMixin);
  validateAlias(obj);
});

test('should copy from properties already applied on object', function() {

  var BaseMixin = SC.Mixin.create({
    foo: 'foo',
    
    computedFoo: SC.computed(function() {
      return 'cfoo';
    })
    
  });
  
  var MyMixin = SC.Mixin.create({
    bar: SC.alias('foo'),
    computedBar: SC.alias('computedFoo'),
    barMethod: SC.alias('fooMethod')
  });

  var obj = {
    fooMethod: function() { return 'FOO'; }
  };
  
  BaseMixin.apply(obj);
  MyMixin.apply(obj);
  
  validateAlias(obj);
});
