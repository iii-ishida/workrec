import React from 'react'
import Enzyme, { shallow, mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

Enzyme.configure({ adapter: new Adapter() })

import Immutable from 'immutable'

import WorkList from './WorkList'
import WorkListItem from './WorkListItem'
import { WorkState } from 'src/api'

describe('<WorkList />', () => {
  it('works の分 WorkListItem を表示すること', () => {
    const works = Immutable.fromJS([{id: 'someid01'}, {id: 'someid02'}, {id: 'someid03'}])
    const worklist = shallow(<WorkList
      works={works}
      fetchWorks={() => {}}
      toggleState={() => {}}
      finishWork={() => {}}
      unfinishWork={() => {}}
      deleteWork={() => {}}
    />)

    expect(worklist.find(WorkListItem).length).toBe(3)
  })

  it('WorkListItem に work を設定すること', () => {
    const work = Immutable.Map({id: 'someid01', title: 'some title', state: WorkState.UNSTARTED})
    const works = Immutable.List([work])

    const fetchWorks = () => {}
    const toggleState = () => {}
    const finishWork = () => {}
    const unfinishWork = () => {}
    const deleteWork = () => {}

    const worklist = shallow(<WorkList
      works={works}
      fetchWorks={fetchWorks}
      toggleState={toggleState}
      finishWork={finishWork}
      unfinishWork={unfinishWork}
      deleteWork={deleteWork}
    />)

    const worklistItem = worklist.find(WorkListItem)
    expect(worklistItem.props().work).toBe(work)
    expect(worklistItem.props().toggleState).toBe(toggleState)
    expect(worklistItem.props().finishWork).toBe(finishWork)
    expect(worklistItem.props().unfinishWork).toBe(unfinishWork)
    expect(worklistItem.props().deleteWork).toBe(deleteWork)
  })
})

