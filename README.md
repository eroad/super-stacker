About
=====

SuperStacker is a tool for writing cloudformation templates in a ruby DSL.

The DSL is parsed and then output as JSON, ready for use with the
CloudFormation toolchain.

Knowledge of CloudFormation templates and basic Ruby knowledge is assumed.

Definitions
===========

Definitions are a declarative way of expressing a cloudformation template. They
allow us to declare parameters, resources, outputs and the description in any
order we want. SuperStacker handles compiling these and building the relevant
JSON object.

description
-----------

The description for a cloudformation stack is specified using the `description`
definition, as shown below:

`description "description for this stack"`

This definition is unique in that it should only be declared once.

See [AWS documentation][1] for further information.

[1]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-description-structure.html

parameter
---------

A parameter to be passed through to the CloudFormation template during stack
creation time.

`parameter "ParameterName", "Type" => "String", "AllowedValues" => ["value1", "value2"]`

The parameter keyword knows how to handle all of the properties specified in the
[AWS documentation][2]. Please consult that for information on accepted
properties.

[2]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html

resource
--------

A resource is a nice clean interface for building a Hash. This is probably best
explained as an example:

    resource "TestName", "MyFakeType" do
      Key "Value"
      NestedHash do
        NestedKey "NestedValue"
      end
    end

would become

    {
      "TestName" => {
        "Type" => "MyFakeType",
        "Key" => "Value",
        "NestedHash" => {
          "NestedKey" => "NestedValue"
        }
      }
    }

Resources should be able to represent any of the resources available in AWS.
Please consult the [AWS Documentation][3] for a complete list of available
resources, types and properties.

[3]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html

output
------

A output is some parameter that you want returned as a result of the stacks
creation. These are often used as parameters for subsequent stacks.

`output "SomeOutputKey", "SomeOutputValue", "SomeOutputDescription"`

Please take a look at the [AWS documentation][4] for a more detailed description
of outputs.

[4]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/concept-outputs.html

mapping
-------

Mappings enable you to specify conditional parameter values in your template.
When used with the intrinsic function Fn::FindInMap, it works like a Case
statement or lookup table.

    mapping "TestMap" do
      MapKey do
        SomeValue "SomeString"
      end
    end

would become

    {
      "TestMap" => {
        "MapKey" => {
          "SomeValue" => "SomeString"
        }
      }
    }

Please take a look at the [AWS documentation][5] for a more detailed description
of mappings.

[5]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/concept-mappings.html

Shorthand Intrinsic Functions
=============================

All of the below functions are essentially shorthand for the AWS cloudformation
functions, and are calculated server side once the template has been uploaded.

Please see the [AWS documentation][6] for a full list of available functions.

[6]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference.html

Fn::Base64
----------

Returns the Base64 representation of the input string.

`Fn::Base64("SomeString")`
=> { "Fn::Base64" => "SomeString" }

Please see the [AWS documentation][7] for further information.

[7]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-base64.html

Fn::FindInMap
-------------

Returns the value of a key from a mapping declared in the Mappings section.

`Fn::FindInMap("SomeMap", "SomeKey", "SomeValue")`
=> { "Fn::FindInMap" => [ "SomeMap", "SomeKey", "SomeValue" ] }

Please see the [AWS documentation][8] for further information.

[8]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-findinmap.html

Fn::GetAtt
----------

Returns the value of an attribute from a resource in the template.

`Fn::GetAtt("SomeResource", "SomeAttribute")`
=> { "Fn::GetAtt" => [ "SomeAttribute", "SomeAttribute" ] }

Please see the [AWS documentation][9] for further information.

[9]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-getatt.html

Fn::GetAZs
----------

Returns an array that lists all Availability Zones for the specified region.

If no region is specified, the region the stack was created in is used.

`Fn::GetAZs`
=> { "Fn::GetAZs" => "" }

Please see the [AWS documentation][10] for further information.

[10]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-getavailabilityzones.html

Fn::Join
--------

Appends a set of values into a single value, separated by the specified
delimiter. If a delimiter is the empty string, the set of values are
concatenated with no delimiter.

`Fn::Join(" ", ["this", "is", "a", "list"]`
=> { "Fn::Join" => [ " ", ["this", "is", "a", "list" ] ] }

Please see the [AWS documentation][11] for further information.

[11]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-join.html

Fn::Select
----------

Returns a single object from a list of objects by index.

`Fn::Select("1", ["zero", "one", "two"])`
=> { "Fn::Select" => [ "1", ["zero", "one", "two" ] ] }

Please see the [AWS documentation][12] for further information.

[12]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-join.html

Ref
---

Ref is used to create a reference to another element of the CloudFormation
template.

`Ref("SomeElement")`
=> { "Ref" => "SomeElement" }

Please see the [AWS documentation][13] for further information.

[13]: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-ref.html

Funnies
=======

escape
------

Due to the way Ruby works, hyphens can not be part of method names so a
declaration like the following will not work:

    mapping 'RegionMap' do
      us-west-2 do
        AMI 'ami-aaaabbbb'
      end
    end

To get around this, the escape function is provided:

    mapping 'RegionMap' do
      escape 'us-west-2' do
        AMI 'ami-aaaabbbb'
      end
    end

Examples
========

Example stacks have been included in the exampes/ directory. Please consult
them for practical use cases. I'll be updating this directory with more examples
as I add features so check back regularly.

To check the output of a sample do something like:

`super-stacker stack examples/ec2-instance/`

