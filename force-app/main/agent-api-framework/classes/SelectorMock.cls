@IsTest
class SelectorMock implements System.StubProvider {
    class MockConfiguration {
        Type type;
        String mehtodName;
        List<Object> parameters;
        Object returnedValue;
    }
    List<MockConfiguration> mockedMethods = new List<MockConfiguration>();

    public void addMock(Type classType, String methodName, List<Obect> params, Object returnedValue) {
        mockedMethods.add(
            new MockConfiguration(
                type = classType,
                methodName = methodName,
                parameters = params,
                returnedValue = returnedValue
            )
        );
    }

    
    public Object handleMethodCall(
        Object stubbedObject, 
        String stubbedMethodName,
        Type returnType, 
        List<Type> listOfParamTypes,
        List<String> listOfParamNames, 
        List<Object> listOfArgs) {

        
        
        switch on stubbedMethodName {
            when 'getByDevName' {
                if (listOfParamTypes[0] == List<String>.class) {
                    List<String> devNames = (List<String>)listOfArgs[0];
                    for(String devName : devNames) {
                        if (botDefinitions.containsKey(devName)) {
                            results.add(botDefinitions.get(devName));
                        }
                    }
                    return results;
                }
            }
        }
        return null;
    }
}